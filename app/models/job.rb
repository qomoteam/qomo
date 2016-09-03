class Job < ApplicationRecord

  include StatusAware

  belongs_to :user

  has_many :units, -> { order idx: :asc }, class_name: 'JobUnit', dependent: :destroy

  default_scope -> { order('created_at DESC') }

  def outdir
    "job-#{self.id}"
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


  def status
    for unit in units.reverse
      if unit && (unit.status != 'waiting')
        return unit.status
      end
    end

    'waiting'
  end


  def destroy!
    user.datastore.delete! self.tmpdir
    self.destroy
  end

end
