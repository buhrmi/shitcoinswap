class CreateCachedVolumes < ActiveRecord::Migration[5.2]
  def change
    create_table :cached_volumes do |t|
      t.integer :base_asset_id
      t.integer :quote_asset_id
      t.string :period
      t.decimal :sum_trades

      t.timestamps

      t.index [:quote_asset_id, :period]
      t.index :base_asset_id
      t.index :quote_asset_id
      t.index :created_at
      t.index :sum_trades
      t.index :period
    end
  end
end
