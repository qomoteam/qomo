class Category < ApplicationRecord

  acts_as_nested_set

  UNCATEGORY_ID = -1

  default_scope -> { order :name }

  before_save :update_slug

  def update_slug
    self.slug = self.name.parameterize
    if Category.find_by_slug(self.slug)
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
    if self.leaf?
      self.tools.active
    else
      self.leaves.collect { |c| c.tools.active }.flatten
    end
  end

  def descendant_shared_pipelines
    if self.leaf?
      self.pipelines.shared
    else
      self.leaves.collect { |c| c.pipelines.shared }.flatten
    end
  end


  def self.uncategory
    Category.find Category::UNCATEGORY_ID
  end

end
