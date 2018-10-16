class CreateAuthorizationCodes < ActiveRecord::Migration[5.2]
  def change
    create_table :authorization_codes do |t|
      t.integer :user_id
      t.string :token
      t.timestamp :used_at

      t.timestamps
    end
  end
end
