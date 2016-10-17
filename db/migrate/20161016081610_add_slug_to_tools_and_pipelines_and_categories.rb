class AddSlugToToolsAndPipelinesAndCategories < ActiveRecord::Migration[5.0]
  def change
    add_column :tools, :slug, :string
    add_index :tools, :slug

    add_column :pipelines, :slug, :string
    add_index :pipelines, :slug

    add_column :categories, :slug, :string
    add_index :categories, :slug, unique: true
  end
end
