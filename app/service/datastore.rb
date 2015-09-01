class Datastore

  attr_reader :home

  def initialize(uid, dir_users)
    @dir_users = dir_users
    @home = File.join @dir_users, uid
  end

  def list(path)
    Dir.glob(File.join @home, path, '*').map do |e|
      Filemeta.new path: rpath(e), size: File.size(e),
                   mtime: File.mtime(e),
                   atime: File.atime(e),
                   ctime: File.ctime(e),
                   kind: File.directory?(e) ? :directory : :file
    end
  end

  def mkdir!(dirpath)
    FileUtils.mkdir_p apath(dirpath)
  end

  def create!
    FileUtils.mkdir_p @home
  end

  def apath(*p)
    File.join @home, p
  end

  def rpath(path)
    path[@home.length+1..-1]
  end

  def directory?

  end

end
