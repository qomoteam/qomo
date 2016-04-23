class AddTechToTool < ActiveRecord::Migration
  def change
    add_column :tools, :tech, :string
  end
end
