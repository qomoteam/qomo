class DeleteNameFromFilerecord < ActiveRecord::Migration[5.0]
  def change
    remove_column :filerecords, :name, :string
  end
end
