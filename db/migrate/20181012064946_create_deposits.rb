class CreateDeposits < ActiveRecord::Migration[5.2]
  def change
    create_table :deposits do |t|
      t.integer :address_id
      t.integer :user_id
      t.integer :asset_id
      t.string :transaction_id
      t.decimal :amount, precision: 50, scale: 20

      t.index :transaction_id, unique: true

      t.integer :withdrawal_to_wallet_id, comment: 'The withdrawal used for consolidation (withdrawal from deposit address into hot wallet)'
      t.timestamps
    end
  end
end
