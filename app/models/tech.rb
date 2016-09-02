class Tech < ApplicationRecord

  default_scope -> { order :name }

end
