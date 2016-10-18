class Category < ApplicationRecord

  acts_as_nested_set

  UNCATEGORY_ID = -1

  default_scope -> { order :name }

  before_save :update_slug

  validates_uniqueness_of :name

  def update_slug
    self.slug = self.name.parameterize
    s = Category.find_by_slug(self.slug)
    if s and s != self
      self.slug = self.slug + '-1'
    end
  end

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


  def descendant_active_tools
    Tool.where(status: 1, category_id: self.self_and_descendants.ids)
  end

  def descendant_shared_pipelines
    Pipeline.where(shared: true, category_id: self.self_and_descendants.ids)
  end


  def self.uncategory
    Category.find Category::UNCATEGORY_ID
  end

end
