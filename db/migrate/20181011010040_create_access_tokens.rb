class CreateAccessTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :access_tokens do |t|
      t.integer :user_id
      t.string :token
      t.timestamp :expires_at
      t.timestamp :logged_out_at

      t.timestamps
    end
  end
end
