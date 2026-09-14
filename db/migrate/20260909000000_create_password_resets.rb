class CreatePasswordResets < ActiveRecord::Migration[8.1]
  def change
    create_table :password_resets do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.string :token_digest, null: false
      t.datetime :expires_at, null: false
      t.datetime :used_at

      t.timestamps

      t.index :token_digest, unique: true
    end
  end
end
