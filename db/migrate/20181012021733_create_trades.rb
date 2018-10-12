class CreateTrades < ActiveRecord::Migration[5.2]
  def change
    create_table :trades do |t|
      t.integer :buy_order_id
      t.integer :sell_order_id
      t.integer :seller_id
      t.integer :buyer_id
      t.integer :base_coin_id
      t.integer :quote_coin_id
      t.decimal :amount, precision: 50, scale: 20
      t.decimal :rate, precision: 50, scale: 20

      t.index :seller_id
      t.index :buyer_id
      t.index :base_coin_id
      t.index :quote_coin_id
      t.index :created_at
      
      t.timestamps
    end
  end
end
