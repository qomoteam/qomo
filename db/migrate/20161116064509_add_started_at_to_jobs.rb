class AddStartedAtToJobs < ActiveRecord::Migration[5.0]
  def change
    add_column :jobs, :started_at, :datetime
    add_column :jobs, :ended_at, :datetime

    remove_column :jobs, :status
    add_column :jobs, :status, :integer, {default: 0}

    remove_column :job_units, :created_at
  end
end
