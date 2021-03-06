class Datastore

  attr_reader :home, :tool_home

  def initialize(uid, dir_users)
    @uid = uid
    @dir_users = dir_users
    @home = Datastore.home_dir(uid, dir_users)
    @tool_home = File.join Config.dir_tools, uid
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

  # Copy the `src` to `dest` dir
  def cp(src, dest)
    src = apath(src)
    dest = apath(dest)
    if File.dirname(src) == File.absolute_path(dest)
      dest = File.join(dest, "Copy_of_#{File.basename(src)}")
    end
    FileUtils.cp_r src, dest
    dest
  end

  def mv!(src, dest)
    src = apath(src)
    dest = apath(dest)
    if File.dirname(src) != File.absolute_path(dest)
      FileUtils.move src, dest
    end
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

  def search(path, q)
    spath = apath(path, '**', "*#{q}*")
    Dir.glob(spath, File::FNM_CASEFOLD).collect {|e| filemeta(e)}
  end

  def filemeta(abs_path)
    if File.directory?(abs_path)
      kind = :directory
    else
      extname = File.extname(abs_path)
      if extname.blank?
        kind = :text
      else
        kind = extname[1..-1].to_sym
      end
    end
    size = File.size(abs_path)
    is_rdout = false
    # There is a '_SUCCESS' file located in Hadoop output directory
    if kind == :directory and File.exist?(File.join abs_path, '_SUCCESS')
      is_rdout = :true
      extname = File.extname(abs_path)
      if extname.blank?
        kind = :text
      else
        kind = extname[1..-1].to_sym
      end
      size = Dir.glob(File.join abs_path, 'part-*').reduce(0) {|mem, e| mem + File.size(e)}
    end
    Filemeta.new apath: abs_path,
                 path: rpath(abs_path),
                 size: size,
                 mtime: File.mtime(abs_path),
                 atime: File.atime(abs_path),
                 ctime: File.ctime(abs_path),
                 is_rdout: is_rdout,
                 kind: kind,
                 owner_id: @uid
  end

  def self.home_dir(uid, dir_users)
    File.join dir_users, uid[0], uid[1], uid
  end

end
