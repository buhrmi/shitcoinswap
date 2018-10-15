class AddLoginDigestToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :login_digest, :string
    add_column :users, :login_token_valid_until, :datetime
  end
end
