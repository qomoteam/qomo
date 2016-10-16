class Category < ApplicationRecord
  extend FriendlyId

  friendly_id :name, use: :slugged

  acts_as_nested_set

  UNCATEGORY_ID = -1

  default_scope -> { order :name }

  has_many :tools

  has_many :pipelines

  def active_tools
    self.tools.where status: 1
  end


  def shared_pipelines
    self.pipelines.where shared: true
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
