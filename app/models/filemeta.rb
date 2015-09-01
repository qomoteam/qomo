class Filemeta

  attr_reader :path, :size, :mtime, :atime, :ctime, :kind

  def initialize(path:, size:, mtime:, atime:, ctime:, kind:)
    @path = path
    @size = size
    @mtime = mtime
    @ctime = ctime
    @atime = atime
    @kind = kind
  end

  def name
    File.basename @path
  end

  def ext
    File.extname @path
  end

  def directory?
    kind == :directory
  end

end
