class AddDescToTool < ActiveRecord::Migration
  def change
    add_column :tools, :desc, :text
  end

end
