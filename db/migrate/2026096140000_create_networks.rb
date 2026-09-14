class CreateNetworks < ActiveRecord::Migration[8.1]
  def change
    # A network is a chain; assets are the tokens on it. The scan cursor lives
    # here because a chain is walked once, no matter how many tokens it carries.
    create_table :networks do |t|
      t.string :name, null: false
      t.string :type, null: false
      t.integer :last_scanned_height

      t.timestamps
    end
  end
end
