class AddAccessionToFilerecords < ActiveRecord::Migration[5.0]
  def change
    remove_index :filerecords, :accession
    add_index :filerecords, :accession, unique: true
  end
end
