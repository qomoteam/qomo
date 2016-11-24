class AddDefaultsToProfiles < ActiveRecord::Migration[5.0]
  def change
    change_column_default :profiles, :timezone, 'Beijing'
    change_column_default :profiles, :country, 'CN'
  end
end
