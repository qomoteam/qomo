class AddFieldsToTool < ActiveRecord::Migration[5.0]

  def change
    rename_column :tools, :usage, :manual

    add_column :tools, :introduction, :text
    add_column :tools, :website, :string
  end

end
