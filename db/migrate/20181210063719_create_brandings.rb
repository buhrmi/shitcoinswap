class CreateBrandings < ActiveRecord::Migration[5.2]
  def change
    create_table :brandings do |t|
      t.string :name
      t.string :domain
      t.integer :admin_id
      t.json :options

      t.timestamps
    end
  end
end
