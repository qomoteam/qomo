class Reader::Reader

  def read(path, start, len)
    if File.directory? path and File.exist?(File.join path, '_SUCCESS')
      parts = Dir.glob(File.join path, 'PART-*')
    else
      File.read path
    end
  end

end
