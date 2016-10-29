class AddSharedAndStatusIndexForPipelinesAndTools < ActiveRecord::Migration[5.0]
  def change
    add_index :pipelines, :shared
    add_index :tools, :status
  end
end
