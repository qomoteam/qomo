class Filemeta

  def initialize(path)
    @path = path
  end

  def name
    File.basename @path
  end

  def ext
    File.extname @path
  end

  def size
    File.size @path
  end

  def mtime
    File.mtime @path
  end

  def atime
    File.atime @path
  end

  def ctime
    File.ctime @path
  end

end
