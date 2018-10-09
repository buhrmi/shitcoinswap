class CreateWithdrawals < ActiveRecord::Migration[5.2]
  def change
    create_table :withdrawals do |t|
      t.string :symbol
      t.integer :user_id
      t.string :receiver_address
      t.string :transaction_id, comment: 'This is the hash of the transaction'
      t.timestamp :submitted_at, comment: 'The time when the transaction was submitted to the blockchain'
      t.decimal :amount, precision: 50, scale: 20
      t.string :status
      t.integer :tries, default: 0
      t.string :error
      t.timestamp :error_at
      t.string :signed_transaction
      t.integer :mined_block
      
      t.index :symbol
      t.index :user_id
      t.index :transaction_id
      
      t.timestamps
    end
  end
end
