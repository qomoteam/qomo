require 'fileutils'
require 'csv'

class Filemeta

  attr_reader :path, :size, :mtime, :atime, :ctime, :type, :is_rdout, :owner_id

  def initialize(opts={})
    @apath = opts[:apath]
    @path = opts[:path]
    @size = opts[:size]
    @mtime = opts[:mtime]
    @ctime = opts[:ctime]
    @atime = opts[:atime]
    @is_rdout = opts[:is_rdout]
    @type = Filetype.get opts[:kind]
    @owner_id = opts[:owner_id]
  end


  def record
    Filerecord.find_by(path: @path, owner_id: @owner_id) || Filerecord.new(path: @path, name: File.basename(@path), owner_id: @owner_id)
  end


  def name
    File.basename @path
  end


  def ext
    File.extname @path
  end


  def directory?
    @type.name == :directory
  end


  def read(offset, len)
    @type.reader.read(@apath, offset, len)
  end

  def read_last(boffset, len)
    @type.reader.read_last @apath, boffset, len
  end

  def raw_read
    if @is_rdout
      Dir.glob(File.join @apath, 'part-*').reduce('') {|mem, e| mem + File.read(e)}
    else
      File.read(@apath)
    end
  end


  def delete!
    FileUtils.rmtree @apath
  end

end
