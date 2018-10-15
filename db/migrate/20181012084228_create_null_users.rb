class CreateNullUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :null_users do |t|

      t.timestamps
    end
  end
end
