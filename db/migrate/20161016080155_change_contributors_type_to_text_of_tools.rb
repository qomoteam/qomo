class ChangeContributorsTypeToTextOfTools < ActiveRecord::Migration[5.0]
  def change

    change_column :tools, :contributors, :text

  end
end
