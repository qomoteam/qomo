class Filerecord < ApplicationRecord

  belongs_to :owner, class_name: 'User'

  after_destroy :santize

  def self.library
    libs = self.where(shared: true, owner: User.find_by_username(Config.admin.username)).order(:path).to_a
    libs = libs.delete_if do |lib|
      flag = false
      libs.each do |other|
        flag = true if other != lib and lib.path.starts_with?(other.path)
      end
      flag
    end
  end

  def self.destroy_subrecords(path, owner_id)
    Filerecord.where("path LIKE :path_like AND owner_id=:owner_id", {path_like: "#{path}%", owner_id: owner_id}).destroy_all
  end


  def self.shared?(uid, path)
    parts = path.split('/')
    (0..(parts.length-1)).reverse_each { |i|
      record = self.find_by(owner_id: uid, path: parts[0..i].join('/'))
      if record
        return record.shared
      end
    }
    return false
  end

  def name
    File.basename self.path
  end

  def meta
    Datastore.new(owner.id, Config.dir_users).get(path)
  end


  private

  def santize
    Filerecord.destroy_subrecords self.path, self.owner.id
  end

end
