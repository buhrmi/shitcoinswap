class CreateAssets < ActiveRecord::Migration[8.1]
  def change
    create_table :assets do |t|
      t.string :type, default: "Asset"
      t.string :name

      t.timestamps
    end
  end
end
