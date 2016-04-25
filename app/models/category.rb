class Category < ActiveRecord::Base

  UNCATEGORY_ID = -1

  acts_as_nested_set

  default_scope -> { order :name }

  has_many :tools

  has_many :pipelines

  def active_tools
    self.tools.select { |tool| tool.active? }
  end


  def delete!
    Pipeline.where(category_id: self.id).update_all(category_id: Category::UNCATEGORY_ID)
    Tool.where(category_id: self.id).update_all(category_id: Category::UNCATEGORY_ID)
    self.delete
  end


  def self.uncategory
    Category.find Category::UNCATEGORY_ID
  end

end
