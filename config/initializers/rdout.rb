class File < IO

  def self.is_rdout?(path)
    File.directory? path and File.exist?(File.join path, '_SUCCESS')
  end

  def is_rdout?
    File.is_rdout? self.path
  end

end
