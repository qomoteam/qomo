class ChangeStatusToSharedInTools < ActiveRecord::Migration[5.0]
  def change
    remove_column :tools, :status
    add_column :tools, :shared, :boolean, {default: false}
    add_index :tools, :shared
  end
end
