class Config < Settingslogic
  source "#{Rails.root}/config/config.yml"
  namespace Rails.env

  def self.revision
    rfile = File.join(Rails.root, 'REVISION')
    File.exist?(rfile) ? File.read(rfile).strip : 'SNAPSHOT'
  end


  def self.dir_users
    File.join nfs, 'users'
  end

  def self.dir_tools
    File.join nfs, 'tools'
  end

  def self.dir_lib(*p)
    File.join nfs, 'libs', p
  end

end
