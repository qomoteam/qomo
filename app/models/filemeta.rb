class Filemeta

  attr_reader :path, :size, :mtime, :atime, :ctime, :kind

  def initialize(apath:, path:, size:, mtime:, atime:, ctime:, kind:)
    @apath = apath
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


  def read
    if @kind == :rdout
      Dir.glob(File.join @apath, 'part-*').reduce('') {|mem, e| mem += File.read(e)}
    else
      File.read @apath
    end
  end


  def delete!
    Dir.delete @apath
  end


  def tpl
    if @kind == :rdout
      return :text
    else
      return @kind
    end
  end

end
