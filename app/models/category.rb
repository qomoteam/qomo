class Category < ActiveRecord::Base
  acts_as_nested_set

  has_many :tools


  def active_tools
    self.tools.select { |tool| tool.active? }
  end

end
