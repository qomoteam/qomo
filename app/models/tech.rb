class Tech < ActiveRecord::Base

  default_scope -> { order :name }

end
