class RemoveRunnableFromTools < ActiveRecord::Migration[5.0]
  def change
    remove_column :tools, :runnable
  end
end
