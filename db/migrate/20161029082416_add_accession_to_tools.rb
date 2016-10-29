class AddAccessionToTools < ActiveRecord::Migration[5.0]
  def change
    add_column :tools, :accession, :integer
    add_index :tools, :accession, unique: true

    remove_column :pipelines, :accession
    add_column :pipelines, :accession, :integer
    add_index :pipelines, :accession, unique: true
  end
end
