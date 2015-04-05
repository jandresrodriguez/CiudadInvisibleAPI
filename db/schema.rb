# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20141219022225) do

  create_table "assets", force: true do |t|
    t.integer  "post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
  end

  add_index "assets", ["post_id"], name: "index_assets_on_post_id"

  create_table "categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: true do |t|
    t.integer  "post_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "text"
    t.integer  "likes"
  end

  add_index "comments", ["post_id"], name: "index_comments_on_post_id"
  add_index "comments", ["user_id"], name: "index_comments_on_user_id"

  create_table "favorites", force: true do |t|
    t.integer  "user_id"
    t.integer  "post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "favorites", ["post_id"], name: "index_favorites_on_post_id"
  add_index "favorites", ["user_id"], name: "index_favorites_on_user_id"

  create_table "notifications", force: true do |t|
    t.integer  "creator_id"
    t.integer  "post_id"
    t.string   "notification_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.text     "message"
    t.integer  "receiver_id"
    t.boolean  "read",              default: false
  end

  add_index "notifications", ["creator_id"], name: "index_notifications_on_creator_id"
  add_index "notifications", ["post_id"], name: "index_notifications_on_post_id"

  create_table "part_of_tours", force: true do |t|
    t.integer  "post_id"
    t.integer  "tour_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order"
  end

  add_index "part_of_tours", ["post_id"], name: "index_part_of_tours_on_post_id"
  add_index "part_of_tours", ["tour_id"], name: "index_part_of_tours_on_tour_id"

  create_table "post_types", force: true do |t|
    t.integer  "post_id"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "post_types", ["category_id"], name: "index_post_types_on_category_id"
  add_index "post_types", ["post_id"], name: "index_post_types_on_post_id"

  create_table "posts", force: true do |t|
    t.string   "title"
    t.string   "description"
    t.string   "image"
    t.datetime "date"
    t.string   "location"
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.float    "latitude"
    t.float    "longitude"
  end

  create_table "posts_categories", force: true do |t|
    t.integer  "post_id"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "posts_categories", ["category_id"], name: "index_posts_categories_on_category_id"
  add_index "posts_categories", ["post_id"], name: "index_posts_categories_on_post_id"

  create_table "relationships", force: true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relationships", ["followed_id"], name: "index_relationships_on_followed_id"
  add_index "relationships", ["follower_id", "followed_id"], name: "index_relationships_on_follower_id_and_followed_id", unique: true
  add_index "relationships", ["follower_id"], name: "index_relationships_on_follower_id"

  create_table "tours", force: true do |t|
    t.integer  "user_id"
    t.string   "city"
    t.integer  "duration"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tours", ["user_id"], name: "index_tours_on_user_id"

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "facebook_id"
    t.string   "twitter_id"
    t.string   "city"
    t.string   "country"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "login_type"
    t.string   "url_avatar"
    t.string   "bio"
    t.string   "token"
    t.string   "device_token"
  end

end
