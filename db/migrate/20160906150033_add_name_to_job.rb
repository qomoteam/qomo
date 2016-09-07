class AddNameToJob < ActiveRecord::Migration[5.0]
  def change
    add_column :jobs, :name, :string
  end
end
