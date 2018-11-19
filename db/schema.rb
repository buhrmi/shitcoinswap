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

ActiveRecord::Schema.define(version: 2018_11_05_014508) do

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

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
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

  create_table "airdrops", force: :cascade do |t|
    t.integer "asset_id"
    t.text "amounts"
    t.integer "user_id"
    t.datetime "executed_at"
    t.string "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "asset_translations", force: :cascade do |t|
    t.integer "asset_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.json "page_content"
    t.index ["asset_id"], name: "index_asset_translations_on_asset_id"
    t.index ["locale"], name: "index_asset_translations_on_locale"
  end

  create_table "assets", force: :cascade do |t|
    t.string "name"
    t.string "native_symbol"
    t.integer "submitter_id", comment: "User ID of user who submitted this token. He should be made admin of this token."
    t.float "cached_rating", default: 0.0
    t.string "platform_id"
    t.string "address"
    t.json "platform_data", default: {}, comment: "Cached information for the asset. Pulled from the platform upon creation"
    t.datetime "delisted_at"
    t.datetime "featured_at"
    t.string "logo_uid"
    t.string "logo_name"
    t.string "brand_color"
    t.string "website"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address", "platform_id"], name: "index_assets_on_address_and_platform_id", unique: true
    t.index ["name"], name: "index_assets_on_name"
  end

  create_table "authorization_codes", force: :cascade do |t|
    t.integer "user_id"
    t.string "code"
    t.datetime "used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_authorization_codes_on_code"
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

  create_table "cached_balances", force: :cascade do |t|
    t.integer "user_id"
    t.integer "asset_id"
    t.decimal "total", default: "0.0"
    t.decimal "available", default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_id"], name: "index_cached_balances_on_asset_id"
    t.index ["user_id", "asset_id"], name: "index_cached_balances_on_user_id_and_asset_id"
    t.index ["user_id"], name: "index_cached_balances_on_user_id"
  end

  create_table "cached_volumes", force: :cascade do |t|
    t.integer "base_asset_id"
    t.integer "quote_asset_id"
    t.string "period"
    t.decimal "sum_trades"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["base_asset_id"], name: "index_cached_volumes_on_base_asset_id"
    t.index ["created_at"], name: "index_cached_volumes_on_created_at"
    t.index ["period"], name: "index_cached_volumes_on_period"
    t.index ["quote_asset_id", "period"], name: "index_cached_volumes_on_quote_asset_id_and_period"
    t.index ["quote_asset_id"], name: "index_cached_volumes_on_quote_asset_id"
    t.index ["sum_trades"], name: "index_cached_volumes_on_sum_trades"
  end

  create_table "deposits", force: :cascade do |t|
    t.integer "address_id"
    t.integer "user_id"
    t.integer "asset_id"
    t.string "transaction_id"
    t.decimal "amount", precision: 50, scale: 20
    t.integer "withdrawal_to_wallet_id", comment: "The withdrawal used for consolidation (withdrawal from deposit address into hot wallet)"
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
    t.decimal "price", precision: 50, scale: 20, comment: "The exchange price (1 BASE = X QUOTE) to use for this order"
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
    t.index ["price"], name: "index_orders_on_price"
    t.index ["quote_asset_id"], name: "index_orders_on_quote_asset_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "pictures", force: :cascade do |t|
    t.integer "uploader_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "platforms", force: :cascade do |t|
    t.string "module"
    t.string "category", default: "token", comment: "Either \"native\" or \"tokens\""
    t.string "native_symbol"
    t.integer "last_scanned_block"
    t.datetime "last_scan_at"
    t.json "data", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "statuses", force: :cascade do |t|
    t.datetime "last_deposits_ran_at", default: "2018-11-19 01:23:41"
    t.datetime "last_withdrawals_ran_at", default: "2018-11-19 01:23:41"
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
    t.decimal "price", precision: 50, scale: 20
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
    t.string "preferred_locale"
    t.boolean "admin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
