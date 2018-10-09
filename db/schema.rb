# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_10_09_094010) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "withdrawals", force: :cascade do |t|
    t.string "symbol"
    t.integer "user_id"
    t.string "receiver_address"
    t.string "transaction_id", comment: "This is the hash of the transaction"
    t.datetime "submitted_at", comment: "The time when the transaction was submitted to the blockchain"
    t.decimal "amount", precision: 50, scale: 20
    t.string "status"
    t.integer "tries", default: 0
    t.string "error"
    t.datetime "error_at"
    t.string "signed_transaction"
    t.integer "mined_block"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["symbol"], name: "index_withdrawals_on_symbol"
    t.index ["transaction_id"], name: "index_withdrawals_on_transaction_id"
    t.index ["user_id"], name: "index_withdrawals_on_user_id"
  end

end
