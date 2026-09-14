class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    enable_extension :citext

    create_table :users do |t|
      t.string :locale, default: "en"
      t.string :name
      t.citext :handle
      t.string :bio
      t.citext :email
      t.json :socials, default: {}
      t.string :password_digest
      t.timestamps

      t.index :handle, unique: true
      t.index :email, unique: true
    end
  end
end
