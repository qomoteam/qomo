class ChangeRefTypeToVotes < ActiveRecord::Migration[5.0]
  def change
    change_column :votes, :votable_id, :string
    change_column :votes, :voter_id, :string
  end
end
