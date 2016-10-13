class AddVersionToTool < ActiveRecord::Migration[5.0]
  def change
    add_column :tools, :version, :string
  end
end
