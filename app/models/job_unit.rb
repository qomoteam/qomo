class JobUnit < ActiveRecord::Base

  include Statusaware

  belongs_to :job
  belongs_to :tool


end
