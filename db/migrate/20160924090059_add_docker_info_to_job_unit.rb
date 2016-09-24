class AddDockerInfoToJobUnit < ActiveRecord::Migration[5.0]
  def change
    add_column :job_units, :docker, :json
  end
end
