class CreateAirdrops < ActiveRecord::Migration[5.2]
  def change
    create_table :airdrops do |t|
      t.integer :asset_id
      t.text :amounts
      t.integer :user_id
      t.timestamp :executed_at
      t.string :memo

      t.timestamps
    end
  end
end
