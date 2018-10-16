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

ActiveRecord::Schema.define(version: 2018_10_15_100911) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_tokens", force: :cascade do |t|
    t.integer "user_id"
    t.string "token"
    t.datetime "expires_at"
    t.datetime "logged_out_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "addresses", force: :cascade do |t|
    t.integer "user_id"
    t.string "module"
    t.string "enc_private_key"
    t.string "public_key"
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address"], name: "index_addresses_on_address"
    t.index ["module"], name: "index_addresses_on_module"
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

  create_table "assets", force: :cascade do |t|
    t.string "name"
    t.string "native_symbol"
    t.float "cached_rating", default: 0.0
    t.string "platform_id"
    t.string "address"
    t.json "platform_data", default: {}, comment: "Cached information for the asset. Pulled from the platform upon creation"
    t.datetime "delisted_at"
    t.string "logo_uid"
    t.string "logo_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address", "platform_id"], name: "index_assets_on_address_and_platform_id", unique: true
    t.index ["name"], name: "index_assets_on_name"
  end

  create_table "authorization_codes", force: :cascade do |t|
    t.integer "user_id"
    t.string "token"
    t.datetime "used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "balance_adjustments", force: :cascade do |t|
    t.integer "asset_id"
    t.integer "user_id"
    t.string "change_type"
    t.integer "change_id"
    t.string "memo"
    t.decimal "amount", precision: 50, scale: 20
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_id", "user_id"], name: "index_balance_adjustments_on_asset_id_and_user_id"
    t.index ["asset_id"], name: "index_balance_adjustments_on_asset_id"
    t.index ["change_id"], name: "index_balance_adjustments_on_change_id"
    t.index ["change_type"], name: "index_balance_adjustments_on_change_type"
    t.index ["user_id"], name: "index_balance_adjustments_on_user_id"
  end

  create_table "deposits", force: :cascade do |t|
    t.integer "address_id"
    t.integer "user_id"
    t.integer "asset_id"
    t.string "transaction_id"
    t.decimal "amount", precision: 50, scale: 20
    t.integer "withdrawal_to_hotwallet", comment: "The withdrawal used for consolidation (withdrawal from deposit address into hot wallet)"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["transaction_id"], name: "index_deposits_on_transaction_id", unique: true
  end

  create_table "orders", force: :cascade do |t|
    t.integer "user_id"
    t.integer "base_asset_id"
    t.integer "quote_asset_id"
    t.string "kind", comment: "\"limit\" or \"market\""
    t.string "side", comment: "\"buy\" or \"sell\""
    t.decimal "rate", precision: 50, scale: 20, comment: "The exchange rate (1 BASE = X QUOTE) to use for this order"
    t.decimal "quantity", precision: 50, scale: 20, default: "0.0", comment: "The quantity (number of units) of the asset to purchase for limit or sell-market orders (buy-market orders use the \"total\" field instead)"
    t.decimal "quantity_filled", precision: 50, scale: 20, default: "0.0", comment: "How many units have been filled."
    t.decimal "total", precision: 50, scale: 20, default: "0.0", comment: "Only used for buy-market orders. The total amount of quote asset to use."
    t.decimal "total_used", precision: 50, scale: 20, default: "0.0", comment: "Only used for buy-market orders. The amount of quote asset that has been used."
    t.datetime "cancelled_at"
    t.datetime "filled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["base_asset_id"], name: "index_orders_on_base_asset_id"
    t.index ["cancelled_at"], name: "index_orders_on_cancelled_at"
    t.index ["filled_at"], name: "index_orders_on_filled_at"
    t.index ["quote_asset_id"], name: "index_orders_on_quote_asset_id"
    t.index ["rate"], name: "index_orders_on_rate"
    t.index ["user_id"], name: "index_orders_on_user_id"
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

  create_table "trades", force: :cascade do |t|
    t.integer "buy_order_id"
    t.integer "sell_order_id"
    t.integer "seller_id"
    t.integer "buyer_id"
    t.integer "base_asset_id"
    t.integer "quote_asset_id"
    t.decimal "amount", precision: 50, scale: 20
    t.decimal "rate", precision: 50, scale: 20
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["base_asset_id"], name: "index_trades_on_base_asset_id"
    t.index ["buyer_id"], name: "index_trades_on_buyer_id"
    t.index ["created_at"], name: "index_trades_on_created_at"
    t.index ["quote_asset_id"], name: "index_trades_on_quote_asset_id"
    t.index ["seller_id"], name: "index_trades_on_seller_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reset_digest"
    t.datetime "reset_sent_at"
  end

  create_table "withdrawals", force: :cascade do |t|
    t.string "asset_id"
    t.integer "user_id"
    t.string "receiver_address"
    t.string "sender_address", comment: "If this is empty, it means that the transaction is sent from some hot wallet"
    t.string "transaction_id", comment: "This is the hash of the transaction"
    t.datetime "submitted_at", comment: "The time when the transaction was submitted to the blockchain"
    t.decimal "amount", precision: 50, scale: 20
    t.string "status"
    t.integer "tries", default: 0
    t.string "error"
    t.datetime "error_at"
    t.string "signed_transaction", comment: "The signed (raw) transaction in hex that can be submitted to the blockchain"
    t.integer "mined_block"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_id"], name: "index_withdrawals_on_asset_id"
    t.index ["transaction_id"], name: "index_withdrawals_on_transaction_id"
    t.index ["user_id"], name: "index_withdrawals_on_user_id"
  end

end
