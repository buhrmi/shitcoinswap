class CreateAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :addresses do |t|
      t.integer :user_id
      t.string :module
      t.string :enc_private_key
      t.string :public_key
      t.string :address

      t.index :address
      t.index :module
      t.index :user_id

      t.timestamps
    end
  end
end
