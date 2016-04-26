class CreateTeches < ActiveRecord::Migration
  def change
    create_table :teches do |t|
      t.string :name
      t.string :htmlClass
    end

    add_belongs_to :tools, :tech
  end
end
