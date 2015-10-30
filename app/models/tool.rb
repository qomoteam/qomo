class Tool < ActiveRecord::Base
  enum status: {
           inactive: 0,
           active: 1
       }

  belongs_to :owner, class_name: 'User'
  belongs_to :category
end
