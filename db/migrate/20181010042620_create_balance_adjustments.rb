class CreateBalanceAdjustments < ActiveRecord::Migration[5.2]
  def change
    create_table :balance_adjustments do |t|
      t.integer :coin_id
      t.integer :user_id
      t.string :change_type
      t.integer :change_id
      t.string :memo
      t.decimal :amount, precision: 50, scale: 20

      t.timestamps

      t.index :coin_id
      t.index :user_id
      t.index [:coin_id, :user_id]
      t.index :change_type
      t.index :change_id
    end
  end
end
