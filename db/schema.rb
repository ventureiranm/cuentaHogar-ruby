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

ActiveRecord::Schema[8.1].define(version: 2026_09_30_030742) do
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
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "api_tokens", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "token_digest", null: false
    t.datetime "expires_at", null: false
    t.datetime "last_used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token_digest"], name: "index_api_tokens_on_token_digest", unique: true
    t.index ["user_id"], name: "index_api_tokens_on_user_id"
  end

  create_table "budgets", force: :cascade do |t|
    t.integer "household_id", null: false
    t.integer "category_id"
    t.date "period", null: false
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_budgets_on_category_id"
    t.index ["household_id", "category_id", "period"], name: "index_budgets_on_household_id_and_category_id_and_period", unique: true
    t.index ["household_id"], name: "index_budgets_on_household_id"
  end

  create_table "categories", force: :cascade do |t|
    t.integer "household_id"
    t.string "name", null: false
    t.string "color", default: "#2F4F4A", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["household_id", "name"], name: "index_categories_on_household_id_and_name", unique: true
    t.index ["household_id"], name: "index_categories_on_household_id"
  end

  create_table "expenses", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "household_id"
    t.integer "category_id"
    t.string "description", null: false
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.date "spent_on", null: false
    t.boolean "recurring", default: false, null: false
    t.integer "source", default: 0, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_expenses_on_category_id"
    t.index ["household_id", "spent_on"], name: "index_expenses_on_household_id_and_spent_on"
    t.index ["household_id"], name: "index_expenses_on_household_id"
    t.index ["user_id"], name: "index_expenses_on_user_id"
  end

  create_table "households", force: :cascade do |t|
    t.string "name", null: false
    t.string "currency", default: "ARS", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "incomes", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "household_id"
    t.string "description", null: false
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.date "received_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["household_id", "received_on"], name: "index_incomes_on_household_id_and_received_on"
    t.index ["household_id"], name: "index_incomes_on_household_id"
    t.index ["user_id"], name: "index_incomes_on_user_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "household_id", null: false
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["household_id", "user_id"], name: "index_memberships_on_household_id_and_user_id", unique: true
    t.index ["household_id"], name: "index_memberships_on_household_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "reminders", force: :cascade do |t|
    t.integer "household_id", null: false
    t.integer "user_id"
    t.string "title", null: false
    t.decimal "amount", precision: 12, scale: 2
    t.date "due_on", null: false
    t.datetime "paid_at"
    t.datetime "notified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["household_id", "due_on"], name: "index_reminders_on_household_id_and_due_on"
    t.index ["household_id"], name: "index_reminders_on_household_id"
    t.index ["user_id"], name: "index_reminders_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "api_tokens", "users"
  add_foreign_key "budgets", "categories"
  add_foreign_key "budgets", "households"
  add_foreign_key "categories", "households"
  add_foreign_key "expenses", "categories"
  add_foreign_key "expenses", "households"
  add_foreign_key "expenses", "users"
  add_foreign_key "incomes", "households"
  add_foreign_key "incomes", "users"
  add_foreign_key "memberships", "households"
  add_foreign_key "memberships", "users"
  add_foreign_key "reminders", "households"
  add_foreign_key "reminders", "users"
  add_foreign_key "sessions", "users"
end
