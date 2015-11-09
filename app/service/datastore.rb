class Datastore

  attr_reader :home

  def initialize(uid, dir_users)
    @dir_users = dir_users
    @home = File.join @dir_users, uid
  end

  def get(path)
    return nil unless File.exist? apath(path)
    filemeta apath(path)
  end

  def list(path)
    Dir.glob(File.join @home, path, '*').map do |e|
      filemeta e
    end
  end

  def mkdir!(dirpath)
    FileUtils.mkdir_p apath(dirpath)
  end

  def delete!(path)
    FileUtils.rmtree apath(path)
  end

  def create!
    FileUtils.mkdir_p @home
  end

  def trash!(dirpath)
    FileUtils.rmtree apath(dirpath)
  end

  def mv!(src, dest)
    FileUtils.move apath(src), apath(dest)
  end

  def save!(path, file)
    FileUtils.copy file, apath(path)
  end

  def apath(*p)
    File.join @home, p
  end

  def rpath(path)
    path[@home.length+1..-1]
  end

  def filemeta(abs_path)
    kind = File.directory?(abs_path) ? :directory : :text
    size = File.size(abs_path)
    if File.directory? abs_path and File.exist?(File.join abs_path, '_SUCCESS')
      kind = :rdout
      size = Dir.glob(File.join abs_path, 'part-*').reduce(0) {|mem, e| mem += File.size(e)}
    end
    Filemeta.new apath: abs_path,
                 path: rpath(abs_path),
                 size: size,
                 mtime: File.mtime(abs_path),
                 atime: File.atime(abs_path),
                 ctime: File.ctime(abs_path),
                 kind: kind
  end

end
