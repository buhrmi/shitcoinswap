class CreatePlatforms < ActiveRecord::Migration[5.2]
  def change
    create_table :platforms do |t|
      t.string :module

      t.string :category, default: 'token', comment: 'Either "native" or "tokens"'
      t.string :native_symbol
      t.integer :last_scanned_block

      t.json :data, default: {}
      
      t.timestamps
    end
  end
end
