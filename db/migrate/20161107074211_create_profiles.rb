class CreateProfiles < ActiveRecord::Migration[5.0]
  def change
    create_table :profiles, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
      t.string :first_name
      t.string :last_name
      t.string :title
      t.string :organization
      t.string :department
      t.string :country
      t.string :location
      t.string :timezone, default: Beijing
      t.string :homepage
      t.text :bio
      t.uuid :user_id
      t.timestamps
    end

    execute 'INSERT INTO profiles(user_id,created_at,updated_at) SELECT id,created_at,updated_at FROM users'

    execute '
UPDATE profiles AS p
SET
first_name=u.first_name,
last_name=u.last_name,
title=u.title,
organization=u.organization,
location=u.location,
timezone=u.timezone,
country=u.country,
bio=u.bio
FROM users AS u
WHERE p.user_id=u.id
'

    remove_column :users, :first_name
    remove_column :users, :last_name
    remove_column :users, :title
    remove_column :users, :organization
    remove_column :users, :location
    remove_column :users, :timezone
    remove_column :users, :homepage
    remove_column :users, :country
    remove_column :users, :bio
  end

end
