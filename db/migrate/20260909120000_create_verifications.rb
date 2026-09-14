class CreateVerifications < ActiveRecord::Migration[8.1]
  def change
    create_table :verifications do |t|
      t.citext :email, null: false
      t.string :kind, null: false, default: "email"
      t.string :code, null: false
      t.datetime :expires_at, null: false
      t.datetime :verified_at

      t.timestamps

      t.index :email
    end
  end
end
