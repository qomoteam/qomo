class AddDescToTool < ActiveRecord::Migration
  def up
    add_column :tools, :desc, :text
  end

  def down
    remove_column :tools, :desc, :text
  end
end
