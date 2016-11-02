class RemoveUniqueIndexOnSlugOfToolsAndPipelines < ActiveRecord::Migration[5.0]
  def change
    remove_index :tools, :slug
    remove_index :pipelines, :slug

    add_index :tools, [:owner_id, :slug]
    add_index :pipelines, [:owner_id, :slug]
  end
end
