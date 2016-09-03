class JobUnit < ApplicationRecord

  include StatusAware

  belongs_to :job
  belongs_to :tool


end
