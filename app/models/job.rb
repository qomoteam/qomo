class Job < ActiveRecord::Base

  include Statusaware

  belongs_to :user

  has_many :units, -> { order idx: :asc }, class_name: 'JobUnit'

end
