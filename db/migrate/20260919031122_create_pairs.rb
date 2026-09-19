class CreatePairs < ActiveRecord::Migration[8.1]
  def change
    create_table :pairs do |t|
      t.belongs_to :base_asset, null: false, foreign_key: { to_table: :assets }
      t.belongs_to :quote_asset, null: false, foreign_key: { to_table: :assets }

      t.timestamps
    end
  end
end
