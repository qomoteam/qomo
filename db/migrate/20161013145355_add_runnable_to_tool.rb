class AddRunnableToTool < ActiveRecord::Migration[5.0]
  def change
    add_column :tools, :runnable, :boolean, {default: true}
  end
end
