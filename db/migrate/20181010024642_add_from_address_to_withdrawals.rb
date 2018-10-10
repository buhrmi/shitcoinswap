class AddFromAddressToWithdrawals < ActiveRecord::Migration[5.2]
  def change
    add_column :withdrawals, :from_address, :string
  end
end
