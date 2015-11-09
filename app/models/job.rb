class Job < ActiveRecord::Base

  include Statusaware

  belongs_to :user

  has_many :units, -> { order idx: :asc }, class_name: 'JobUnit', dependent: :delete_all

  def outdir
    "job-#{self.id}"
  end


  def accession
    "QP-#{self.id}"
  end


  def progress
    self.units.success.count*1.0 / self.units.count
  end

end
