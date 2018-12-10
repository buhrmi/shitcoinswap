class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.string :preferred_locale
      t.integer :branding_id, comment: 'The branding ID the user used to sign up'
      t.boolean :admin
      
      t.timestamps
    end
  end
end
