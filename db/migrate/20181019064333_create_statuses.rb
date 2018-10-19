class CreateStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :statuses do |t|
      t.timestamp :last_deposits_ran_at, default: Time.now
      t.timestamp :last_withdrawals_ran_at, default: Time.now

      t.timestamps
    end
  end
end
