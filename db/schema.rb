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

ActiveRecord::Schema.define(version: 2018_10_10_051918) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "coins", force: :cascade do |t|
    t.string "name"
    t.string "native_symbol"
    t.float "cached_rating", default: 0.0
    t.string "platform_id"
    t.string "address"
    t.json "platform_data", default: {}, comment: "Cached information for the coin. Pulled from the platform upon creation"
    t.datetime "delisted_at"
    t.string "logo_uid"
    t.string "logo_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address", "platform_id"], name: "index_coins_on_address_and_platform_id", unique: true
    t.index ["name"], name: "index_coins_on_name"
  end

  create_table "platforms", force: :cascade do |t|
    t.string "module"
    t.string "category", default: "token", comment: "Either \"native\" or \"tokens\""
    t.string "native_symbol"
    t.integer "last_scanned_block"
    t.json "data", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "user_id"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "remember_digest"
  end

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
    t.string "from_address"
    t.index ["symbol"], name: "index_withdrawals_on_symbol"
    t.index ["transaction_id"], name: "index_withdrawals_on_transaction_id"
    t.index ["user_id"], name: "index_withdrawals_on_user_id"
  end

end
