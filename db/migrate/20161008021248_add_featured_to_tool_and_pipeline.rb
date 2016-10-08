class AddFeaturedToToolAndPipeline < ActiveRecord::Migration[5.0]
  def change
    add_column :tools, :featured, :integer, {default: 0}
    add_index :tools, :featured

    add_column :pipelines, :featured, :integer, {default: 0}
    add_index :pipelines, :featured
  end
end
