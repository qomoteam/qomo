class AddAria2JobIdToFilerecords < ActiveRecord::Migration[5.0]
  def change
    add_column :filerecords, :aid, :string
  end
end
