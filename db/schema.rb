# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_14_140000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "assets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.bigint "network_id", null: false
    t.string "type", default: "Asset"
    t.datetime "updated_at", null: false
    t.index ["network_id"], name: "index_assets_on_network_id"
  end

  create_table "balances", force: :cascade do |t|
    t.bigint "asset_id", null: false
    t.decimal "available", precision: 36, scale: 18, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.decimal "locked", precision: 36, scale: 18, default: "0.0", null: false
    t.decimal "total", precision: 36, scale: 18, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["asset_id"], name: "index_balances_on_asset_id"
    t.index ["user_id", "asset_id"], name: "index_balances_on_user_id_and_asset_id", unique: true
    t.index ["user_id"], name: "index_balances_on_user_id"
  end

  create_table "deposits", force: :cascade do |t|
    t.decimal "amount", precision: 36, scale: 18, default: "0.0", null: false
    t.bigint "asset_id", null: false
    t.integer "block_height"
    t.integer "confirmations", default: 0
    t.datetime "created_at", null: false
    t.datetime "credited_at"
    t.string "tx"
    t.integer "tx_idx"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "wallet_id", null: false
    t.index ["asset_id"], name: "index_deposits_on_asset_id"
    t.index ["user_id"], name: "index_deposits_on_user_id"
    t.index ["wallet_id", "tx", "tx_idx"], name: "index_deposits_on_wallet_id_and_tx_and_tx_idx", unique: true
    t.index ["wallet_id"], name: "index_deposits_on_wallet_id"
  end

  create_table "identities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.json "info"
    t.string "provider"
    t.string "provider_id"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["provider", "provider_id"], name: "index_identities_on_provider_and_provider_id", unique: true
  end

  create_table "networks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "last_scanned_height"
    t.string "name", null: false
    t.string "type", null: false
    t.datetime "updated_at", null: false
  end

  create_table "password_resets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "token_digest", null: false
    t.datetime "updated_at", null: false
    t.datetime "used_at"
    t.bigint "user_id", null: false
    t.index ["token_digest"], name: "index_password_resets_on_token_digest", unique: true
    t.index ["user_id"], name: "index_password_resets_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "bio"
    t.datetime "created_at", null: false
    t.citext "email"
    t.citext "handle"
    t.string "locale", default: "en"
    t.string "name"
    t.string "password_digest"
    t.json "socials", default: {}
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["handle"], name: "index_users_on_handle", unique: true
  end

  create_table "verifications", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.citext "email", null: false
    t.datetime "expires_at", null: false
    t.string "kind", default: "email", null: false
    t.datetime "updated_at", null: false
    t.datetime "verified_at"
    t.index ["email"], name: "index_verifications_on_email"
  end

  create_table "wallets", force: :cascade do |t|
    t.string "address"
    t.bigint "asset_id", null: false
    t.datetime "created_at", null: false
    t.string "path"
    t.integer "sequential_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["asset_id"], name: "index_wallets_on_asset_id"
    t.index ["user_id"], name: "index_wallets_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "assets", "networks"
  add_foreign_key "balances", "users"
  add_foreign_key "deposits", "assets"
  add_foreign_key "deposits", "users"
  add_foreign_key "deposits", "wallets"
  add_foreign_key "password_resets", "users"
  add_foreign_key "wallets", "assets"
  add_foreign_key "wallets", "users"
end
