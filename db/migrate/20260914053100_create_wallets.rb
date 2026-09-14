class CreateWallets < ActiveRecord::Migration[8.1]
  def change
    create_table :wallets do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :asset, null: false, foreign_key: true
      t.string :address
      t.integer :sequential_id
      t.string :path

      t.timestamps
    end
  end
end
