class AddSharedAndStatusIndexForPipelinesAndTools < ActiveRecord::Migration[5.0]
  def change
    add_index :pipelines, :shared
    add_index :tools, :status

    # This maybe added by mistake
    remove_column :categories, :tech_id_id
  end
end
