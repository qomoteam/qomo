require 'fileutils'
require 'zip'

class Tool < ApplicationRecord

  attr_accessor :upload

  acts_as_votable
  acts_as_ordered_taggable

  ratyrate_rateable :usability, :performance, :reliability

  paginates_per 10

  before_destroy :rmdir
  before_save :sanitize

  validates_presence_of :name, :category, :contributors, :desc, :tech

  include AccessionAware
  accession_aware prefix: 'QT'

  include SlugAware
  slug_aware for: :name

  scope :featured, -> { where('featured>?', 0).where(shared: true).order(featured: :desc) }

  scope :shared, -> { where(shared: true).order(:name) }
  scope :unshared, -> { where(shared: false).order(:name) }

  default_scope -> { order('name ASC') }

  belongs_to :owner, class_name: 'User'
  belongs_to :category

  belongs_to :tech

  has_many :releases, -> { order(created_at: :desc) }


  def rmdir
    FileUtils.rmtree self.dirpath
  end


  def inputs
    self.params&.select { |k| k['type'].downcase == 'input' } || []
  end


  # @deprecated
  def output
    outputs[0]
  end


  def outputs
    self.params&.select { |k| k['type'].downcase == 'output' } || []
  end


  def io
    inputs << output
  end


  def normal_params
    self.params&.reject { |k| %w(input output tmp).include? k['type'].downcase } || []
  end


  def dirpath_tmp
    File.join(Settings.home, "tmp-#{self.dirname}")
  end


  def dirpath
    File.join self.owner.datastore.tool_home, self.dirname.blank? ? self.id : self.dirname
  end


  def copy_upload!
    unless Dir.exist? dirpath
      FileUtils.mkdir_p dirpath
    end
    unless self.upload.nil?
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


  def files
    pl = self.dirpath.length + 1
    Dir.glob("#{self.dirpath}/**/*").reject { |e| File.directory? e }.collect { |e| {path: e[pl..-1], exe: File.executable?(e)} }
  end


  def citation
    self.publications.collect { |e| e['citation'].to_i }.sum
  end


  def category_path
    path = []
    c = self.category
    while c
      path << c
      c = c.parent
    end
    path.reverse
  end

  def download_count
    self.releases.sum &:download_count
  end

  def abbrev
    pa = self.name.split
    if pa.size > 1
      r = pa.collect { |e| e[0].upcase }.join
    else
      r = self.name.chars.select { |e| /[[:upper:]]/.match(e)}.join
    end
    if r.size < 2
      r = self.name[0..3].upcase
    end
    r
  end

  private

  def sanitize
    if self.command.present?
      self.command = self.command.split(/\r?\n/).each { |e| e.strip }.join("\n")
    end
  end

end
