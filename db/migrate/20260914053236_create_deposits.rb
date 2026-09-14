class CreateDeposits < ActiveRecord::Migration[8.1]
  def change
    create_table :deposits do |t|
      t.belongs_to :asset, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true

      # The address we saw the payment on.
      t.belongs_to :wallet, null: false, foreign_key: true

      t.string :tx
      t.integer :tx_idx

      # What the output paid, in the asset's own units.
      t.decimal :amount, precision: 36, scale: 18, null: false, default: 0

      t.integer :confirmations, default: 0
      t.integer :block_height

      # When the deposit was added to the user's balance, so it only happens once.
      t.datetime :credited_at

      t.timestamps

      t.index [ :wallet_id, :tx, :tx_idx ], unique: true
    end
  end
end
