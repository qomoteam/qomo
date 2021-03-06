class Filerecord < ApplicationRecord

  belongs_to :owner, class_name: 'User'

  after_destroy :santize

  before_update :update_subrecords

  include AccessionAware
  accession_aware prefix: 'QD'

  def self.subrecords(path, owner_id)
    where("path LIKE :path_like AND owner_id=:owner_id", {path_like: "#{path}/%", owner_id: owner_id})
  end

  def self.library
    libs = self.where(shared: true, owner: User.with_role(:admin)).order(:path).to_a
    libs = libs.delete_if do |lib|
      flag = false
      libs.each do |other|
        flag = true if other != lib and lib.path.starts_with?(other.path)
      end
      flag
    end
  end

  def self.destroy_subrecords(path, owner_id)
    subrecords(path, owner_id).destroy_all
  end


  # Attr `shared` used to access DB column `shared`
  # while this method used to judge whether this record is shared
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

  def aria2_status
    status = ARIA2.query_status(self.aid)
    if status['status'] == 'complete'
      self.aid = nil
      self.save
    end
    {status: status['status'], progress: status['progress']}
  end

  private

  def santize
    Filerecord.destroy_subrecords self.path, self.owner.id
  end

  def update_subrecords
    Filerecord.subrecords(self.path_was, self.owner.id).each do |record|
      record.path = self.path + record.path[self.path_was.length..-1]
      record.save
    end
  end

end
