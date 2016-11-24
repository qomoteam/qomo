class AddFieldsToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :postal_code, :string
    add_column :profiles, :phone, :string
    add_column :profiles, :fax, :string
    add_column :profiles, :lab, :string

    add_column :profiles, :state, :string
    add_column :profiles, :street, :string

    add_column :profiles, :mid_name, :string

    add_column :profiles, :reseach_area, :text

    rename_column :profiles, :location, :city
  end
end
