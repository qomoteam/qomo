class RenameToolToModule < ActiveRecord::Migration[5.0]
  def change
    rename_table :tools, :tool_modules
  end
end
