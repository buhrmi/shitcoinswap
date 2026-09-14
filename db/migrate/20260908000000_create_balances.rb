class CreateBalances < ActiveRecord::Migration[8.1]
  def change
    create_table :balances do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :asset, null: false
      t.decimal :locked, null: false, precision: 36, scale: 18, default: 0
      t.decimal :available, null: false, precision: 36, scale: 18, default: 0
      t.decimal :total, null: false, precision: 36, scale: 18, default: 0

      t.timestamps

      t.index [ :user_id, :asset_id ], unique: true
    end
  end
end
