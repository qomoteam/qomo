class JobUnit < ApplicationRecord

  include Statusaware

  belongs_to :job
  belongs_to :tool


end
