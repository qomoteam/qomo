class Config < Settingslogic
  source "#{Rails.root}/config/config.yml"
  namespace Rails.env

  def self.revision
    rfile = File.join(Rails.root, 'REVISION')
    File.exist?(rfile) ? File.read(rfile).strip : 'SNAPSHOT'
  end

end
