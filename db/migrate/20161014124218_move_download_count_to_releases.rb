class MoveDownloadCountToReleases < ActiveRecord::Migration[5.0]
  def change
    remove_column :tools, :download_count
    remove_column :tools, :version
    add_column :releases, :download_count, :integer, {default: 0}
  end
end
