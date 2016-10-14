require 'fileutils'

class Release < ApplicationRecord

  belongs_to :tool

  attr_accessor :downloads

  after_destroy :delete_downloads

  validates_presence_of :version
  validates_presence_of :tool

  def download_path
    File.join self.tool.dirpath, '.downloads', self.id.to_s
  end

  def copy_download_files!
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
      {filename: e[pl..-1], size: File.size(e), updated_at: File.mtime(e)}
    end
  end


  private

  def delete_downloads
    FileUtils.rmtree self.download_path
  end

end
