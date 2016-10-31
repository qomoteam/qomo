class ChangeStringToUuidInVotes < ActiveRecord::Migration[5.0]
  def change
    change_column :votes, :voter_id, 'UUID USING voter_id::uuid'
    change_column :votes, :votable_id, 'UUID USING voter_id::uuid'
  end
end
