class Datastore

  attr_reader :home

  def initialize(uid, nfs)
    @home = File.join nfs, 'users', uid
  end

  def list(path)
    Dir.glob(File.join @home, path, '*').map do |e|
      Filemeta.new e
    end
  end

  def create!
    FileUtils.mkdir_p @home
  end

end
