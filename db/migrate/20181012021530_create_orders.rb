class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.integer :user_id
      t.integer :base_asset_id
      t.integer :quote_asset_id
      t.string :kind,                                                     comment: '"limit" or "market"'
      t.string :side,                                                     comment: '"buy" or "sell"'
      t.decimal :price, precision: 50, scale: 20,                          comment: 'The exchange price (1 BASE = X QUOTE) to use for this order'
      t.decimal :quantity, default: 0, precision: 50, scale: 20,          comment: 'The quantity (number of units) of the asset to purchase for limit or sell-market orders (buy-market orders use the "total" field instead)'
      t.decimal :quantity_filled, default: 0, precision: 50, scale: 20,   comment: 'How many units have been filled.'
      t.decimal :total, default: 0, precision: 50, scale: 20,             comment: 'Only used for buy-market orders. The total amount of quote asset to use.'
      t.decimal :total_used, default: 0, precision: 50, scale: 20,        comment: 'Only used for buy-market orders. The amount of quote asset that has been used.'
      t.timestamp :cancelled_at
      t.timestamp :filled_at
      t.timestamps

      t.index :user_id
      t.index :base_asset_id
      t.index :quote_asset_id
      t.index :price
      t.index :cancelled_at
      t.index :filled_at
    end
  end
end
