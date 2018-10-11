class CreateSessions < ActiveRecord::Migration[5.2]
  def change
    create_table :sessions do |t|
      t.integer :user_id
      t.string :authorization
      t.timestamp :expires_at
      t.timestamp :logged_out_at

      t.timestamps
    end
  end
end
