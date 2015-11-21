class FakeTables < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string  :email, null: false
      t.string  :password, null: false
      t.integer :posts_count, default: 0
      t.timestamps null: false
    end

    create_table :user_details do |t|
      t.references :user
      t.string  :first_name, null: false
      t.string  :last_name, null: false
      t.boolean :admin, default: false
      t.timestamps null: false
    end
    
    create_table :posts do |t|
      t.references :user
      t.string  :title, null: false
      t.string  :body, null: false
      t.timestamps null: false
    end
  end

  def down
    drop_table :users
    drop_table :user_details
    drop_table :posts
  end
end