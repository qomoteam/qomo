class Job < ApplicationRecord

  include StatusAware

  belongs_to :user

  has_many :units, -> { order idx: :asc }, class_name: 'JobUnit', dependent: :destroy

  default_scope -> { order('created_at DESC') }

  def outdir
    "jobs/#{self.name}".gsub(/\s/, '_')
  end


  def tmpdir
    File.join outdir, '.tmp'
  end


  def accession
    self.id
  end


  def progress
    self.units.success.count*1.0 / self.units.count
  end

  def destroy!
    user.datastore.delete! self.tmpdir
    self.destroy
  end

  def start?
    self.status != 'waiting'
  end

  def end?
    %w(fail success).include? self.status
  end

end
