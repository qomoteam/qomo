class CreateReleases < ActiveRecord::Migration[5.0]
  def change
    create_table :releases do |t|
      t.string :version
      t.uuid :tool_id
      t.integer :download_count, default: 0
      t.timestamps
    end
  end
end
