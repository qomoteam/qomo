class AddAuditToTools < ActiveRecord::Migration[5.0]
  def change
    add_column :tools, :audit, :boolean, {default: false}
  end
end
