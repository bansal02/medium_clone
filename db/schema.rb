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

ActiveRecord::Schema[7.0].define(version: 2023_08_05_070643) do
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

  create_table "articles", force: :cascade do |t|
    t.string "title"
    t.integer "author_id"
    t.integer "topic_id"
    t.string "text"
    t.json "comments", default: []
    t.json "likes", default: []
    t.integer "views", default: 0
    t.json "states", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image"
    t.index ["author_id"], name: "index_articles_on_author_id"
    t.index ["topic_id"], name: "index_articles_on_topic_id"
  end

  create_table "authors", force: :cascade do |t|
    t.string "name", default: "FullName"
    t.string "username"
    t.string "interest", default: "adventure"
    t.string "speciality", default: "adventure"
    t.json "article_ids", default: []
    t.json "following_ids", default: []
    t.json "saved_ids", default: []
    t.integer "views", default: 0
    t.json "shared_lists", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "drafts", force: :cascade do |t|
    t.string "title"
    t.integer "author_id"
    t.integer "topic_id"
    t.json "states", default: []
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_drafts_on_author_id"
    t.index ["topic_id"], name: "index_drafts_on_topic_id"
  end

  create_table "lists", force: :cascade do |t|
    t.integer "author_id"
    t.string "name"
    t.json "article_ids", default: []
    t.json "shared_with", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_lists_on_author_id"
  end

  create_table "statuses", force: :cascade do |t|
    t.string "username"
    t.integer "requests", default: 0
    t.integer "views", default: 1
    t.date "subscription_date", default: "2023-08-12"
    t.date "last_request_date", default: "2023-08-12"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "topics", force: :cascade do |t|
    t.string "name"
    t.json "article_ids", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "username", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jti", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "articles", "authors"
  add_foreign_key "articles", "topics"
  add_foreign_key "drafts", "authors"
  add_foreign_key "drafts", "topics"
  add_foreign_key "lists", "authors"
end
