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

ActiveRecord::Schema[7.1].define(version: 2025_10_18_155724) do
  create_table "addresses", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "address_type"
    t.string "full_name"
    t.string "phone_number"
    t.string "line1"
    t.string "line2"
    t.string "city"
    t.string "state"
    t.string "postal_code"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

  create_table "attribute_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "attribute_values", force: :cascade do |t|
    t.integer "attribute_type_id", null: false
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attribute_type_id"], name: "index_attribute_values_on_attribute_type_id"
  end

  create_table "brands", force: :cascade do |t|
    t.string "name"
    t.string "logo_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cart_items", force: :cascade do |t|
    t.integer "cart_id", null: false
    t.integer "product_variant_id", null: false
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["product_variant_id"], name: "index_cart_items_on_product_variant_id"
  end

  create_table "carts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.integer "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_categories_on_parent_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "product_variant_id", null: false
    t.integer "quantity"
    t.decimal "price_at_purchase"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_variant_id"], name: "index_order_items_on_product_variant_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "shipping_address_id", null: false
    t.integer "billing_address_id", null: false
    t.string "status"
    t.string "payment_status"
    t.string "shipping_method"
    t.decimal "total_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["billing_address_id"], name: "index_orders_on_billing_address_id"
    t.index ["shipping_address_id"], name: "index_orders_on_shipping_address_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "product_images", force: :cascade do |t|
    t.integer "product_variant_id", null: false
    t.string "image_url"
    t.string "alt_text"
    t.integer "display_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_variant_id"], name: "index_product_images_on_product_variant_id"
  end

  create_table "product_variant_attributes", force: :cascade do |t|
    t.integer "product_variant_id", null: false
    t.integer "attribute_value_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attribute_value_id"], name: "index_product_variant_attributes_on_attribute_value_id"
    t.index ["product_variant_id"], name: "index_product_variant_attributes_on_product_variant_id"
  end

  create_table "product_variants", force: :cascade do |t|
    t.integer "product_id", null: false
    t.string "sku"
    t.decimal "price"
    t.decimal "discounted_price"
    t.integer "stock_quantity"
    t.float "weight_kg"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_variants_on_product_id"
    t.index ["sku"], name: "index_product_variants_on_sku", unique: true
  end

  create_table "products", force: :cascade do |t|
    t.integer "supplier_profile_id", null: false
    t.integer "category_id", null: false
    t.integer "brand_id", null: false
    t.string "name"
    t.text "description"
    t.integer "status"
    t.integer "verified_by_admin_id"
    t.datetime "verified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brand_id"], name: "index_products_on_brand_id"
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["supplier_profile_id"], name: "index_products_on_supplier_profile_id"
    t.index ["verified_by_admin_id"], name: "index_products_on_verified_by_admin_id"
  end

  create_table "return_items", force: :cascade do |t|
    t.integer "return_request_id", null: false
    t.integer "order_item_id", null: false
    t.integer "quantity"
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_item_id"], name: "index_return_items_on_order_item_id"
    t.index ["return_request_id"], name: "index_return_items_on_return_request_id"
  end

  create_table "return_media", force: :cascade do |t|
    t.integer "return_item_id", null: false
    t.string "media_url"
    t.string "media_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["return_item_id"], name: "index_return_media_on_return_item_id"
  end

  create_table "return_requests", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "order_id", null: false
    t.string "status"
    t.string "resolution_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_return_requests_on_order_id"
    t.index ["user_id"], name: "index_return_requests_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "product_id", null: false
    t.integer "rating"
    t.text "comment"
    t.boolean "verified_purchase"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_reviews_on_product_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "supplier_profiles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "company_name"
    t.string "gst_number"
    t.text "description"
    t.string "website_url"
    t.boolean "verified"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_supplier_profiles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "phone_number"
    t.string "password_digest"
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["phone_number"], name: "index_users_on_phone_number", unique: true
  end

  create_table "wishlist_items", force: :cascade do |t|
    t.integer "wishlist_id", null: false
    t.integer "product_variant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_variant_id"], name: "index_wishlist_items_on_product_variant_id"
    t.index ["wishlist_id"], name: "index_wishlist_items_on_wishlist_id"
  end

  create_table "wishlists", force: :cascade do |t|
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_wishlists_on_user_id"
  end

  add_foreign_key "addresses", "users"
  add_foreign_key "attribute_values", "attribute_types"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "product_variants"
  add_foreign_key "carts", "users"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "product_variants"
  add_foreign_key "orders", "billing_addresses"
  add_foreign_key "orders", "shipping_addresses"
  add_foreign_key "orders", "users"
  add_foreign_key "product_images", "product_variants"
  add_foreign_key "product_variant_attributes", "attribute_values"
  add_foreign_key "product_variant_attributes", "product_variants"
  add_foreign_key "product_variants", "products"
  add_foreign_key "products", "brands"
  add_foreign_key "products", "categories"
  add_foreign_key "products", "supplier_profiles"
  add_foreign_key "products", "users", column: "verified_by_admin_id"
  add_foreign_key "return_items", "order_items"
  add_foreign_key "return_items", "return_requests"
  add_foreign_key "return_media", "return_items"
  add_foreign_key "return_requests", "orders"
  add_foreign_key "return_requests", "users"
  add_foreign_key "reviews", "products"
  add_foreign_key "reviews", "users"
  add_foreign_key "supplier_profiles", "users"
  add_foreign_key "wishlist_items", "product_variants"
  add_foreign_key "wishlist_items", "wishlists"
  add_foreign_key "wishlists", "users"
end
