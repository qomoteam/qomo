class AddCategoryToPipeline < ActiveRecord::Migration

  def change
    add_belongs_to :pipelines, :category
  end

end
