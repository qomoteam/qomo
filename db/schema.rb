ActiveRecord::Schema.define(version: 20141221052429) do
  enable_extension 'uuid-ossp'

  create_table :tools, id: :uuid do |t|
    t.string :name, null: false
    t.string :contributors
    t.uuid :owner_id, index: true
    t.integer :category_id, index: true
    t.text :command
    t.json :params
    t.text :usage

    t.integer :status, default: 0

    t.string :dirname

    t.timestamps
  end

  add_index :tools, [:name], unique: true

  create_table :categories do |t|
    t.string :name
    t.integer :parent_id, :null => true, :index => true
    t.integer :lft, :null => false, :index => true
    t.integer :rgt, :null => false, :index => true

    # optional fields
    t.integer :depth, :null => false, :default => 0
    t.integer :children_count, :null => false, :default => 0
  end


  create_table :pipelines, id: :uuid do |t|
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


  create_table :users, id: :uuid do |t|
    t.string :first_name
    t.string :last_name
    t.string :title
    t.string :organization
    t.string :location
    t.string :timezone
    t.string :homepage

    t.string :role, default: 'user'

    ## Database authenticatable
    t.string :email,              null: false, default: ''
    t.string :encrypted_password, null: false, default: ''

    ## Recoverable
    t.string   :reset_password_token
    t.datetime :reset_password_sent_at

    ## Rememberable
    t.datetime :remember_created_at

    ## Trackable
    t.integer  :sign_in_count, default: 0, null: false
    t.datetime :current_sign_in_at
    t.datetime :last_sign_in_at
    t.inet     :current_sign_in_ip
    t.inet     :last_sign_in_ip

    ## Confirmable
    t.string   :confirmation_token
    t.datetime :confirmed_at
    t.datetime :confirmation_sent_at
    t.string   :unconfirmed_email # Only if using reconfirmable

    ## Lockable
    # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
    # t.string   :unlock_token # Only if unlock strategy is :email or :both
    # t.datetime :locked_at


    t.timestamps null: false
  end

  add_index :users, :email,                unique: true
  add_index :users, :reset_password_token, unique: true
  add_index :users, :confirmation_token,   unique: true
  #add_index :users, :unlock_token,         unique: true

end
