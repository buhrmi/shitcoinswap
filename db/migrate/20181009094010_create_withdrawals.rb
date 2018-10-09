class CreateWithdrawals < ActiveRecord::Migration[5.2]
  def change
    create_table :withdrawals do |t|
      t.string :symbol
      t.integer :user_id
      t.string :receiver_address
      t.string :transaction_id
      t.timestamp :submitted_at
      t.decimal :amount
      t.string :status
      t.integer :tries
      t.string :error
      t.timestamp :error_at
      t.string :signed_transaction

      t.timestamps
    end
  end
end
