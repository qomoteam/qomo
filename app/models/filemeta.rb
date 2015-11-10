class Filemeta

  attr_reader :path, :size, :mtime, :atime, :ctime, :kind

  def initialize(opts={})
    @apath = opts[:apath]
    @path = opts[:path]
    @size = opts[:size]
    @mtime = opts[:mtime]
    @ctime = opts[:ctime]
    @atime = opts[:atime]
    @kind = opts[:kind]
    @owner_id = opts[:owner_id]
  end


  def record
    Filerecord.find_by(path: @path, owner_id: @owner_id) || Filerecord.new(path: @path, owner_id: @owner_id)
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
    case @kind
      when :rdout
        :text
      else
        @kind
    end
  end

end
