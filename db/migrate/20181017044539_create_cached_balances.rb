class CreateCachedBalances < ActiveRecord::Migration[5.2]
  def change
    create_table :cached_balances do |t|
      t.integer :user_id
      t.integer :asset_id

      t.decimal :total, default: 0
      t.decimal :available, default: 0

      t.timestamps

      t.index :user_id
      t.index :asset_id
      t.index [:user_id, :asset_id]
    end
  end
end
