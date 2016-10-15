class AddPublicationsToTools < ActiveRecord::Migration[5.0]

  def change
    add_column :tools, :publications, :json, {default: []}
  end

end
