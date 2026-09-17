class CreateAssets < ActiveRecord::Migration[8.1]
  def change
    create_table :assets do |t|
      t.belongs_to :network, foreign_key: true
      t.string :type, default: "Asset"
      t.string :description
      t.string :contract_address

      # Metadata
      t.string :name
      t.string :symbol
      t.integer :decimals
      t.jsonb :metadata

      t.timestamps
      t.index :symbol
      t.index :contract_address
    end
  end
end
