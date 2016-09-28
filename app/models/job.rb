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


  def status
    units.reverse.each do |unit|
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


  def end?
    status == 'success' or status == 'fail'
  end

end
