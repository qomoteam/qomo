ActiveRecord::Schema.define(version: 20141221052429) do

  create_table :pipelines do |t|
    t.string :pid
    t.string :title
    t.string :contributor
    t.text :desc

    t.text :boxes
    t.text :connections

    t.text :params

    t.boolean :public, default: false
    t.timestamps
  end

end
