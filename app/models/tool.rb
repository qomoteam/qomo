require 'fileutils'
require 'zip'

class Tool < ApplicationRecord

  attr_accessor :upload, :downloads

  before_destroy :rmdir
  before_save :sanitize

  scope :featured, -> { where('featured>?', 0).where(status: 1).order(featured: :desc) }

  scope :active_runnable, -> { where(runnable: true, status: 1).order(:name) }

  enum status: {
      inactive: 0,
      active: 1
  }

  default_scope -> { order('name ASC') }

  belongs_to :owner, class_name: 'User'
  belongs_to :category

  belongs_to :tech

  def self.active_count
    Tool.active.count
  end


  def active?
    self.status == 1
  end

  def rmdir
    FileUtils.rmtree self.dirpath
  end


  def inputs
    self.params.select { |k| k['type'].downcase == 'input' }
  end


  # @deprecated
  def output
    outputs[0]
  end


  def outputs
    self.params.select { |k| k['type'].downcase == 'output' }
  end


  def io
    inputs << output
  end


  def normal_params
    self.params.reject { |k| %w(input output tmp).include? k['type'].downcase }
  end


  def dirpath_tmp
    File.join(Settings.home, "tmp-#{self.dirname}")
  end


  def dirpath
    File.join Config.dir_tools, self.owner.id, self.dirname.blank? ? self.id : self.dirname
  end


  def copy_upload!
    unless Dir.exist? dirpath
      FileUtils.mkdir_p dirpath
    end
    if self.upload
      if self.upload.original_filename.end_with? '.zip'
        Zip::File.open(self.upload.path) do |zip_file|
          zip_file.each do |entry|
            entry.extract("#{dirpath}/#{entry.name}")
          end
        end
      else
        File.open("#{dirpath}/#{self.upload.original_filename}", "wb") { |f| f.write(self.upload.tempfile.read) }
      end
    end
  end

  def download_path
    File.join dirpath, '.downloads'
  end

  def copy_downloads!
    unless Dir.exist? download_path
      FileUtils.mkdir_p download_path
    end
    self.downloads ||= []
    self.downloads.each do |df|
      File.open("#{download_path}/#{df.original_filename}", "wb") { |f| f.write(df.tempfile.read) }
    end
  end

  def download_files
    pl = download_path.length + 1
    Dir.glob(File.join download_path, '*').collect do |e|
      {filename: e[pl..-1], updated_at: File.mtime(e)}
    end
  end

  def files
    pl = self.dirpath.length + 1
    Dir.glob("#{self.dirpath}/**/*").reject { |e| File.directory? e }.collect { |e| {path: e[pl..-1], exe: File.executable?(e)} }
  end


  private

  def sanitize
    self.command = self.command.split(/\r?\n/).each { |e| e.strip }.join("\n")
  end

end
