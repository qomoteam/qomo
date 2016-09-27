class Filerecord < ApplicationRecord

  belongs_to :owner, class_name: 'User'

  scope :library, -> { where(shared: true, owner: User.find_by_username(Config.admin.username)).order :path }

  def self.shared?(uid, path)
    parts = path.split('/')
    (0..(parts.length-1)).each { |i|
      record = self.find_by(owner_id: uid, path: parts[0..i].join('/'))
      if record
        return record.shared
      end
    }
    return false
  end


  def meta
    Datastore.new(owner.id, Config.dir_users).get(path)
  end


end
