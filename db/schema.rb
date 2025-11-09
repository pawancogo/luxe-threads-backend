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

ActiveRecord::Schema[7.1].define(version: 2025_11_08_043510) do
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
    t.datetime "deleted_at"
    t.string "label", limit: 100
    t.string "alternate_phone", limit: 20
    t.string "landmark"
    t.decimal "latitude", precision: 10, scale: 8
    t.decimal "longitude", precision: 11, scale: 8
    t.bigint "pincode_id"
    t.boolean "is_verified", default: false
    t.string "verification_status", limit: 50
    t.text "delivery_instructions"
    t.boolean "is_default_shipping", default: false
    t.boolean "is_default_billing", default: false
    t.index ["deleted_at"], name: "index_addresses_on_deleted_at"
    t.index ["is_default_billing"], name: "index_addresses_on_is_default_billing"
    t.index ["is_default_shipping"], name: "index_addresses_on_is_default_shipping"
    t.index ["latitude", "longitude"], name: "idx_addresses_location"
    t.index ["postal_code"], name: "idx_addresses_pincode"
    t.index ["user_id", "address_type"], name: "index_addresses_on_user_type"
    t.index ["user_id"], name: "index_addresses_on_user_id"
    t.index ["verification_status"], name: "index_addresses_on_verification_status"
  end

  create_table "admin_activities", force: :cascade do |t|
    t.integer "admin_id", null: false
    t.string "action", limit: 100, null: false
    t.string "resource_type", limit: 50
    t.integer "resource_id"
    t.text "description"
    t.text "activity_changes", default: "{}"
    t.string "ip_address", limit: 50
    t.text "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_admin_activities_on_action"
    t.index ["admin_id"], name: "index_admin_activities_on_admin_id"
    t.index ["created_at"], name: "index_admin_activities_on_created_at"
    t.index ["resource_type", "resource_id"], name: "index_admin_activities_on_resource_type_and_resource_id"
  end

  create_table "admin_role_assignments", force: :cascade do |t|
    t.integer "admin_id", null: false
    t.integer "rbac_role_id", null: false
    t.integer "assigned_by_id"
    t.datetime "assigned_at", null: false
    t.datetime "expires_at"
    t.boolean "is_active", default: true
    t.json "custom_permissions", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id", "is_active"], name: "index_admin_role_assignments_on_admin_id_and_is_active"
    t.index ["admin_id", "rbac_role_id"], name: "index_admin_role_assignments_on_admin_and_role", unique: true
    t.index ["admin_id"], name: "index_admin_role_assignments_on_admin_id"
    t.index ["assigned_by_id"], name: "index_admin_role_assignments_on_assigned_by_id"
    t.index ["rbac_role_id"], name: "index_admin_role_assignments_on_rbac_role_id"
  end

  create_table "admins", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "phone_number"
    t.string "password_digest"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "email_verified"
    t.datetime "temp_password_expires_at"
    t.boolean "password_reset_required"
    t.string "temp_password_digest"
    t.datetime "deleted_at"
    t.boolean "is_active", default: true
    t.boolean "is_blocked", default: false
    t.datetime "last_login_at"
    t.datetime "password_changed_at"
    t.text "permissions", default: "{}"
    t.string "invitation_token"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_expires_at"
    t.integer "invited_by_id"
    t.datetime "invitation_accepted_at"
    t.string "invitation_status"
    t.index ["deleted_at"], name: "index_admins_on_deleted_at"
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["invitation_status"], name: "index_admins_on_invitation_status"
    t.index ["invitation_token"], name: "index_admins_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_admins_on_invited_by_id"
    t.index ["is_active"], name: "index_admins_on_is_active"
    t.index ["phone_number"], name: "index_admins_on_phone_number", unique: true
  end

  create_table "attribute_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "display_name"
    t.string "data_type", default: "string"
    t.boolean "is_variant_attribute", default: false
    t.text "applicable_product_types", default: "[]"
    t.text "applicable_categories", default: "[]"
    t.string "display_type", default: "select"
    t.text "validation_rules", default: "{}"
    t.index ["data_type"], name: "index_attribute_types_on_data_type"
    t.index ["is_variant_attribute"], name: "index_attribute_types_on_is_variant_attribute"
    t.index ["name"], name: "index_attribute_types_on_name", unique: true
  end

  create_table "attribute_values", force: :cascade do |t|
    t.integer "attribute_type_id", null: false
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "display_value"
    t.integer "display_order", default: 0
    t.text "metadata", default: "{}"
    t.index ["attribute_type_id", "display_order"], name: "index_attribute_values_on_attribute_type_id_and_display_order"
    t.index ["attribute_type_id", "value"], name: "index_attribute_values_on_attribute_type_id_and_value", unique: true
    t.index ["attribute_type_id"], name: "index_attribute_values_on_attribute_type_id"
  end

  create_table "audit_logs", force: :cascade do |t|
    t.string "auditable_type", limit: 50, null: false
    t.integer "auditable_id", null: false
    t.string "action", limit: 50, null: false
    t.text "changes", default: "{}"
    t.integer "user_id"
    t.string "user_type", limit: 50
    t.string "ip_address", limit: 50
    t.text "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_audit_logs_on_action"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable_type_and_auditable_id"
    t.index ["created_at"], name: "index_audit_logs_on_created_at"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "brands", force: :cascade do |t|
    t.string "name"
    t.string "logo_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.text "short_description"
    t.string "banner_url"
    t.string "country_of_origin"
    t.integer "founded_year"
    t.string "website_url"
    t.boolean "active", default: true
    t.integer "products_count", default: 0
    t.integer "active_products_count", default: 0
    t.string "meta_title"
    t.text "meta_description"
    t.index ["active"], name: "index_brands_on_active"
    t.index ["slug"], name: "index_brands_on_slug", unique: true
  end

  create_table "cart_items", force: :cascade do |t|
    t.integer "cart_id", null: false
    t.integer "product_variant_id", null: false
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.decimal "price_when_added", precision: 10, scale: 2
    t.index ["cart_id", "created_at"], name: "index_cart_items_on_cart_created"
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["deleted_at"], name: "index_cart_items_on_deleted_at"
    t.index ["product_variant_id"], name: "index_cart_items_on_product_variant_id"
  end

  create_table "carts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_carts_on_deleted_at"
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.integer "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.integer "level", default: 0
    t.text "path"
    t.integer "sort_order", default: 0
    t.text "short_description"
    t.string "image_url"
    t.string "banner_url"
    t.string "icon_url"
    t.string "meta_title"
    t.text "meta_description"
    t.text "meta_keywords"
    t.boolean "featured", default: false
    t.integer "products_count", default: 0
    t.integer "active_products_count", default: 0
    t.text "require_brand", default: "{}"
    t.text "require_attributes", default: "[]"
    t.index ["featured"], name: "index_categories_on_featured"
    t.index ["level"], name: "index_categories_on_level"
    t.index ["parent_id"], name: "index_categories_on_parent_id"
    t.index ["path"], name: "index_categories_on_path"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
    t.index ["sort_order"], name: "index_categories_on_sort_order"
  end

  create_table "coupon_usages", force: :cascade do |t|
    t.integer "coupon_id", null: false
    t.integer "user_id", null: false
    t.integer "order_id", null: false
    t.decimal "discount_amount", precision: 10, scale: 2, null: false
    t.decimal "order_amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coupon_id", "user_id"], name: "index_coupon_usages_on_coupon_id_and_user_id"
    t.index ["coupon_id"], name: "index_coupon_usages_on_coupon_id"
    t.index ["created_at"], name: "index_coupon_usages_on_created_at"
    t.index ["order_id"], name: "index_coupon_usages_on_order_id"
    t.index ["user_id"], name: "index_coupon_usages_on_user_id"
  end

  create_table "coupons", force: :cascade do |t|
    t.string "code", limit: 50, null: false
    t.string "name", limit: 255, null: false
    t.text "description"
    t.string "coupon_type", limit: 50, null: false
    t.decimal "discount_value", precision: 10, scale: 2, null: false
    t.decimal "max_discount_amount", precision: 10, scale: 2
    t.decimal "min_order_amount", precision: 10, scale: 2, default: "0.0"
    t.datetime "valid_from", null: false
    t.datetime "valid_until", null: false
    t.boolean "is_active", default: true
    t.integer "max_uses"
    t.integer "max_uses_per_user", default: 1
    t.integer "current_uses", default: 0
    t.text "applicable_categories"
    t.text "applicable_products"
    t.text "applicable_brands"
    t.text "applicable_suppliers"
    t.text "exclude_categories"
    t.text "exclude_products"
    t.text "applicable_user_ids"
    t.text "exclude_user_ids"
    t.boolean "new_users_only", default: false
    t.boolean "first_order_only", default: false
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_coupons_on_code", unique: true
    t.index ["created_by_id"], name: "index_coupons_on_created_by_id"
    t.index ["is_active"], name: "index_coupons_on_is_active"
    t.index ["valid_from", "valid_until"], name: "index_coupons_on_valid_from_and_valid_until"
  end

  create_table "email_templates", force: :cascade do |t|
    t.string "template_type", null: false
    t.string "subject", null: false
    t.text "body_html"
    t.text "body_text"
    t.string "from_email"
    t.string "from_name"
    t.boolean "is_active", default: true
    t.json "variables", default: {}
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["template_type"], name: "index_email_templates_on_template_type", unique: true
  end

  create_table "email_verifications", force: :cascade do |t|
    t.string "email"
    t.string "otp"
    t.datetime "expires_at"
    t.integer "attempts"
    t.integer "max_attempts"
    t.boolean "verified"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "verifiable_type"
    t.integer "verifiable_id"
    t.datetime "verified_at"
    t.index ["email"], name: "index_email_verifications_on_email", unique: true
    t.index ["expires_at"], name: "index_email_verifications_on_expires_at"
    t.index ["verifiable_type", "verifiable_id"], name: "index_email_verifications_on_verifiable"
    t.index ["verifiable_type", "verifiable_id"], name: "index_email_verifications_on_verifiable_type_and_verifiable_id"
  end

  create_table "inventory_transactions", force: :cascade do |t|
    t.string "transaction_id", limit: 100, null: false
    t.integer "product_variant_id", null: false
    t.integer "supplier_profile_id", null: false
    t.string "transaction_type", limit: 50, null: false
    t.integer "quantity", null: false
    t.integer "balance_after", null: false
    t.string "reference_type", limit: 50
    t.integer "reference_id"
    t.text "reason"
    t.text "notes"
    t.integer "performed_by_id"
    t.string "performed_by_type", limit: 50
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_inventory_transactions_on_created_at"
    t.index ["performed_by_id"], name: "index_inventory_transactions_on_performed_by_id"
    t.index ["product_variant_id"], name: "index_inventory_transactions_on_product_variant_id"
    t.index ["reference_type", "reference_id"], name: "idx_on_reference_type_reference_id_30e938d718"
    t.index ["supplier_profile_id"], name: "index_inventory_transactions_on_supplier_profile_id"
    t.index ["transaction_id"], name: "index_inventory_transactions_on_transaction_id", unique: true
    t.index ["transaction_type"], name: "index_inventory_transactions_on_transaction_type"
  end

  create_table "login_sessions", force: :cascade do |t|
    t.string "user_type", null: false
    t.integer "user_id", null: false
    t.string "session_token", limit: 255, null: false
    t.string "jwt_token_id", limit: 255
    t.string "ip_address", limit: 50
    t.string "country", limit: 100
    t.string "region", limit: 100
    t.string "city", limit: 100
    t.string "timezone", limit: 50
    t.string "device_type", limit: 50
    t.string "device_name", limit: 100
    t.string "os_name", limit: 50
    t.string "os_version", limit: 50
    t.string "browser_name", limit: 50
    t.string "browser_version", limit: 50
    t.text "user_agent", limit: 500
    t.string "screen_resolution", limit: 50
    t.string "viewport_size", limit: 50
    t.string "connection_type", limit: 50
    t.boolean "is_mobile", default: false
    t.boolean "is_tablet", default: false
    t.boolean "is_desktop", default: false
    t.string "login_method", limit: 50
    t.boolean "is_successful", default: true
    t.string "failure_reason", limit: 255
    t.datetime "logged_in_at", null: false
    t.datetime "logged_out_at"
    t.datetime "last_activity_at"
    t.boolean "is_active", default: true
    t.boolean "is_expired", default: false
    t.text "metadata", default: "{}"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ip_address"], name: "index_login_sessions_on_ip_address"
    t.index ["logged_in_at"], name: "index_login_sessions_on_logged_in_at"
    t.index ["session_token"], name: "index_login_sessions_on_session_token", unique: true
    t.index ["user_type", "user_id", "is_active"], name: "index_login_sessions_on_user_type_and_user_id_and_is_active"
    t.index ["user_type", "user_id"], name: "index_login_sessions_on_user"
  end

  create_table "loyalty_points_transactions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "transaction_type", limit: 50, null: false
    t.integer "points", null: false
    t.integer "balance_after", null: false
    t.string "reference_type", limit: 50
    t.integer "reference_id"
    t.text "description"
    t.date "expiry_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_loyalty_points_transactions_on_created_at"
    t.index ["reference_type", "reference_id"], name: "idx_on_reference_type_reference_id_c332ebb6eb"
    t.index ["transaction_type"], name: "index_loyalty_points_transactions_on_transaction_type"
    t.index ["user_id", "transaction_type", "created_at"], name: "index_loyalty_points_on_user_type_created"
    t.index ["user_id"], name: "index_loyalty_points_transactions_on_user_id"
  end

  create_table "navigation_items", force: :cascade do |t|
    t.string "key", limit: 100, null: false
    t.string "label", limit: 100, null: false
    t.string "icon", limit: 50
    t.string "path_method", limit: 100, null: false
    t.string "section", limit: 100
    t.text "required_permissions"
    t.boolean "require_super_admin", default: false
    t.boolean "always_visible", default: false
    t.boolean "can_view", default: true
    t.boolean "can_create", default: false
    t.boolean "can_edit", default: false
    t.boolean "can_delete", default: false
    t.text "view_permissions"
    t.text "create_permissions"
    t.text "edit_permissions"
    t.text "delete_permissions"
    t.integer "display_order", default: 0
    t.boolean "is_active", default: true
    t.boolean "is_system", default: false
    t.text "description"
    t.string "controller_name", limit: 100
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_active"], name: "index_navigation_items_on_is_active"
    t.index ["is_system"], name: "index_navigation_items_on_is_system"
    t.index ["key"], name: "index_navigation_items_on_key", unique: true
    t.index ["section", "display_order"], name: "index_navigation_items_on_section_and_display_order"
  end

  create_table "notification_preferences", force: :cascade do |t|
    t.integer "user_id", null: false
    t.text "preferences", default: "{\n          \"email\": {\n            \"order_updates\": true,\n            \"promotions\": true,\n            \"reviews\": true,\n            \"system\": true\n          },\n          \"sms\": {\n            \"order_updates\": true,\n            \"promotions\": false,\n            \"reviews\": false,\n            \"system\": false\n          },\n          \"push\": {\n            \"order_updates\": true,\n            \"promotions\": true,\n            \"reviews\": true,\n            \"system\": true\n          }\n        }"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notification_preferences_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "title", limit: 255, null: false
    t.text "message", null: false
    t.string "notification_type", limit: 50, null: false
    t.text "data", default: "{}"
    t.boolean "is_read", default: false
    t.datetime "read_at"
    t.boolean "sent_email", default: false
    t.boolean "sent_sms", default: false
    t.boolean "sent_push", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_notifications_on_created_at"
    t.index ["is_read"], name: "index_notifications_on_is_read"
    t.index ["notification_type"], name: "index_notifications_on_notification_type"
    t.index ["user_id", "created_at"], name: "index_unread_notifications_on_user_created", where: "is_read = false"
    t.index ["user_id", "is_read", "created_at"], name: "index_notifications_on_user_read_created"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "product_variant_id", null: false
    t.integer "quantity"
    t.decimal "price_at_purchase"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "supplier_profile_id", null: false
    t.string "product_name"
    t.text "product_variant_attributes", default: "{}"
    t.string "product_image_url"
    t.decimal "discounted_price", precision: 10, scale: 2
    t.decimal "final_price", precision: 10, scale: 2
    t.string "currency", default: "INR"
    t.string "fulfillment_status", default: "pending"
    t.datetime "shipped_at"
    t.datetime "delivered_at"
    t.string "tracking_number"
    t.string "tracking_url"
    t.decimal "supplier_commission", precision: 10, scale: 2
    t.boolean "supplier_paid", default: false
    t.datetime "supplier_paid_at"
    t.string "supplier_payment_id"
    t.boolean "is_returnable", default: true
    t.date "return_deadline"
    t.boolean "return_requested", default: false
    t.index ["fulfillment_status"], name: "index_order_items_on_fulfillment_status"
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_variant_id"], name: "index_order_items_on_product_variant_id"
    t.index ["return_deadline"], name: "index_order_items_on_return_deadline"
    t.index ["shipped_at"], name: "index_order_items_on_shipped_at"
    t.index ["supplier_paid"], name: "index_order_items_on_supplier_paid"
    t.index ["supplier_profile_id", "fulfillment_status", "created_at"], name: "index_order_items_on_supplier_status_created"
    t.index ["supplier_profile_id"], name: "index_order_items_on_supplier_profile_id"
    t.index ["tracking_number"], name: "index_order_items_on_tracking_number"
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
    t.datetime "deleted_at"
    t.string "tracking_number"
    t.string "order_number"
    t.datetime "status_updated_at"
    t.text "status_history", default: "[]"
    t.string "payment_method"
    t.string "payment_id"
    t.string "payment_gateway"
    t.datetime "paid_at"
    t.decimal "tax_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "coupon_discount", precision: 10, scale: 2, default: "0.0"
    t.integer "loyalty_points_used", default: 0
    t.decimal "loyalty_points_discount", precision: 10, scale: 2, default: "0.0"
    t.string "currency", default: "INR"
    t.string "shipping_provider"
    t.string "tracking_url"
    t.date "estimated_delivery_date"
    t.date "actual_delivery_date"
    t.datetime "delivery_slot_start"
    t.datetime "delivery_slot_end"
    t.text "customer_notes"
    t.text "internal_notes"
    t.text "cancellation_reason"
    t.datetime "cancelled_at"
    t.string "cancelled_by"
    t.index ["billing_address_id"], name: "index_orders_on_billing_address_id"
    t.index ["cancelled_at"], name: "index_orders_on_cancelled_at"
    t.index ["deleted_at"], name: "index_orders_on_deleted_at"
    t.index ["estimated_delivery_date"], name: "index_orders_on_estimated_delivery_date"
    t.index ["order_number"], name: "index_orders_on_order_number", unique: true
    t.index ["paid_at"], name: "index_orders_on_paid_at"
    t.index ["payment_id"], name: "index_orders_on_payment_id"
    t.index ["payment_method"], name: "index_orders_on_payment_method"
    t.index ["shipping_address_id"], name: "index_orders_on_shipping_address_id"
    t.index ["status", "created_at"], name: "index_orders_on_status_created"
    t.index ["status_updated_at"], name: "index_orders_on_status_updated_at"
    t.index ["tracking_number"], name: "index_orders_on_tracking_number"
    t.index ["user_id", "status", "created_at"], name: "index_orders_on_user_status_created"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "payment_refunds", force: :cascade do |t|
    t.string "refund_id", limit: 100, null: false
    t.integer "payment_id", null: false
    t.integer "order_id", null: false
    t.integer "order_item_id"
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "currency", limit: 10, default: "INR"
    t.string "reason", limit: 255, null: false
    t.text "description"
    t.string "status", limit: 50, default: "pending", null: false
    t.string "gateway_refund_id", limit: 255
    t.text "gateway_response"
    t.integer "processed_by_id"
    t.datetime "processed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_payment_refunds_on_order_id"
    t.index ["order_item_id"], name: "index_payment_refunds_on_order_item_id"
    t.index ["payment_id"], name: "index_payment_refunds_on_payment_id"
    t.index ["processed_by_id"], name: "index_payment_refunds_on_processed_by_id"
    t.index ["refund_id"], name: "index_payment_refunds_on_refund_id", unique: true
    t.index ["status"], name: "index_payment_refunds_on_status"
  end

  create_table "payment_transactions", force: :cascade do |t|
    t.string "transaction_id", limit: 100, null: false
    t.integer "payment_id"
    t.integer "order_id"
    t.string "transaction_type", limit: 50, null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "currency", limit: 10, default: "INR"
    t.string "status", limit: 50, null: false
    t.text "gateway_response"
    t.text "failure_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_payment_transactions_on_created_at"
    t.index ["order_id"], name: "index_payment_transactions_on_order_id"
    t.index ["payment_id"], name: "index_payment_transactions_on_payment_id"
    t.index ["status"], name: "index_payment_transactions_on_status"
    t.index ["transaction_id"], name: "index_payment_transactions_on_transaction_id", unique: true
    t.index ["transaction_type"], name: "index_payment_transactions_on_transaction_type"
  end

  create_table "payments", force: :cascade do |t|
    t.string "payment_id", limit: 100, null: false
    t.integer "order_id", null: false
    t.integer "user_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "currency", limit: 10, default: "INR"
    t.string "payment_method", limit: 50, null: false
    t.string "payment_gateway", limit: 50
    t.string "gateway_transaction_id", limit: 255
    t.string "gateway_payment_id", limit: 255
    t.text "gateway_response"
    t.string "status", limit: 50, default: "pending", null: false
    t.text "failure_reason"
    t.string "card_last4", limit: 4
    t.string "card_brand", limit: 50
    t.string "upi_id", limit: 255
    t.string "wallet_type", limit: 50
    t.decimal "refund_amount", precision: 10, scale: 2, default: "0.0"
    t.string "refund_status", limit: 50
    t.string "refund_id", limit: 255
    t.datetime "refunded_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_payments_on_created_at"
    t.index ["gateway_transaction_id"], name: "index_payments_on_gateway_transaction_id"
    t.index ["order_id", "status", "created_at"], name: "index_payments_on_order_status_created"
    t.index ["order_id"], name: "index_payments_on_order_id"
    t.index ["payment_id"], name: "index_payments_on_payment_id", unique: true
    t.index ["status"], name: "index_payments_on_status"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "pincode_serviceability", force: :cascade do |t|
    t.string "pincode", limit: 20, null: false
    t.boolean "is_serviceable", default: true
    t.boolean "is_cod_available", default: false
    t.string "city", limit: 100
    t.string "state", limit: 100
    t.string "district", limit: 100
    t.string "zone", limit: 50
    t.integer "standard_delivery_days"
    t.integer "express_delivery_days"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city"], name: "index_pincode_serviceability_on_city"
    t.index ["pincode"], name: "index_pincode_serviceability_on_pincode", unique: true
    t.index ["state"], name: "index_pincode_serviceability_on_state"
  end

  create_table "product_attributes", force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "attribute_value_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attribute_value_id"], name: "index_product_attributes_on_attribute_value_id"
    t.index ["product_id", "attribute_value_id"], name: "index_product_attributes_on_product_id_and_attribute_value_id", unique: true
    t.index ["product_id"], name: "index_product_attributes_on_product_id"
  end

  create_table "product_images", force: :cascade do |t|
    t.integer "product_variant_id", null: false
    t.string "image_url"
    t.string "alt_text"
    t.integer "display_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "product_id"
    t.string "thumbnail_url"
    t.string "medium_url"
    t.string "large_url"
    t.string "image_type"
    t.string "color_dominant"
    t.integer "file_size_bytes"
    t.integer "width_pixels"
    t.integer "height_pixels"
    t.string "mime_type"
    t.index ["image_type"], name: "index_product_images_on_image_type"
    t.index ["product_id"], name: "index_product_images_on_product_id"
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
    t.string "barcode"
    t.string "ean_code"
    t.string "isbn"
    t.decimal "cost_price", precision: 10, scale: 2
    t.decimal "mrp", precision: 10, scale: 2
    t.string "currency", default: "INR"
    t.integer "reserved_quantity", default: 0
    t.integer "available_quantity", default: 0
    t.integer "low_stock_threshold", default: 10
    t.boolean "is_low_stock", default: false
    t.boolean "out_of_stock", default: false
    t.boolean "is_available", default: true
    t.text "variant_attributes", default: "{}"
    t.integer "primary_image_id"
    t.integer "total_returned", default: 0
    t.integer "total_refunded", default: 0
    t.index ["available_quantity"], name: "index_product_variants_on_available_quantity"
    t.index ["barcode"], name: "index_product_variants_on_barcode"
    t.index ["is_available"], name: "index_product_variants_on_is_available"
    t.index ["is_low_stock"], name: "index_product_variants_on_is_low_stock"
    t.index ["out_of_stock"], name: "index_product_variants_on_out_of_stock"
    t.index ["primary_image_id"], name: "index_product_variants_on_primary_image_id"
    t.index ["product_id", "is_available", "stock_quantity"], name: "index_variants_on_product_available_stock"
    t.index ["product_id", "price"], name: "index_available_variants_on_product_price", where: "is_available = true AND stock_quantity > 0"
    t.index ["product_id"], name: "index_product_variants_on_product_id"
    t.index ["sku"], name: "index_product_variants_on_sku", unique: true
  end

  create_table "product_views", force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "user_id"
    t.integer "product_variant_id"
    t.string "session_id", limit: 255
    t.string "ip_address", limit: 50
    t.text "user_agent"
    t.string "referrer_url", limit: 500
    t.string "source", limit: 50
    t.datetime "viewed_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "created_at"], name: "index_product_views_on_product_and_created_at"
    t.index ["product_id"], name: "index_product_views_on_product_id"
    t.index ["product_variant_id"], name: "index_product_views_on_product_variant_id"
    t.index ["session_id"], name: "index_product_views_on_session_id"
    t.index ["user_id"], name: "index_product_views_on_user_id"
    t.index ["viewed_at"], name: "index_product_views_on_viewed_at"
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
    t.datetime "deleted_at"
    t.string "slug"
    t.text "short_description"
    t.text "highlights", default: "[]"
    t.string "product_type"
    t.datetime "status_changed_at"
    t.integer "status_changed_by_id"
    t.string "meta_title"
    t.text "meta_description"
    t.text "meta_keywords"
    t.text "search_keywords", default: "[]"
    t.text "tags", default: "[]"
    t.text "product_attributes", default: "{}"
    t.decimal "base_price", precision: 10, scale: 2
    t.decimal "base_discounted_price", precision: 10, scale: 2
    t.decimal "base_mrp", precision: 10, scale: 2
    t.decimal "length_cm", precision: 8, scale: 2
    t.decimal "width_cm", precision: 8, scale: 2
    t.decimal "height_cm", precision: 8, scale: 2
    t.decimal "weight_kg", precision: 8, scale: 3
    t.text "rating_distribution", default: "{}"
    t.integer "total_clicks_count", default: 0
    t.decimal "conversion_rate", precision: 5, scale: 2, default: "0.0"
    t.integer "total_stock_quantity", default: 0
    t.integer "low_stock_variants_count", default: 0
    t.boolean "is_featured", default: false
    t.boolean "is_bestseller", default: false
    t.boolean "is_new_arrival", default: false
    t.boolean "is_trending", default: false
    t.datetime "published_at"
    t.text "rejection_reason"
    t.index ["brand_id"], name: "index_products_on_brand_id"
    t.index ["category_id", "created_at"], name: "index_active_products_on_category_created", where: "status = 'active'"
    t.index ["category_id", "status"], name: "index_products_on_category_status"
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["deleted_at"], name: "index_products_on_deleted_at"
    t.index ["is_bestseller"], name: "index_products_on_is_bestseller"
    t.index ["is_featured"], name: "index_products_on_is_featured"
    t.index ["is_new_arrival"], name: "index_products_on_is_new_arrival"
    t.index ["is_trending"], name: "index_products_on_is_trending"
    t.index ["product_type"], name: "index_products_on_product_type"
    t.index ["published_at"], name: "index_products_on_published_at"
    t.index ["rejection_reason"], name: "index_products_on_rejection_reason", where: "rejection_reason IS NOT NULL"
    t.index ["slug"], name: "index_products_on_slug", unique: true
    t.index ["status_changed_by_id"], name: "index_products_on_status_changed_by_id"
    t.index ["supplier_profile_id", "status", "created_at"], name: "index_products_on_supplier_status_created"
    t.index ["supplier_profile_id"], name: "index_products_on_supplier_profile_id"
    t.index ["verified_by_admin_id"], name: "index_products_on_verified_by_admin_id"
  end

  create_table "promotions", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.text "description"
    t.string "promotion_type", limit: 50, null: false
    t.decimal "discount_percentage", precision: 5, scale: 2
    t.decimal "discount_amount", precision: 10, scale: 2
    t.datetime "start_date", null: false
    t.datetime "end_date", null: false
    t.boolean "is_active", default: true
    t.text "applicable_categories"
    t.text "applicable_products"
    t.text "applicable_brands"
    t.string "banner_image_url", limit: 500
    t.string "thumbnail_url", limit: 500
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_promotions_on_created_by_id"
    t.index ["is_active"], name: "index_promotions_on_is_active"
    t.index ["start_date", "end_date"], name: "index_promotions_on_start_date_and_end_date"
  end

  create_table "rbac_permissions", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.string "slug", limit: 100, null: false
    t.string "resource_type", limit: 50, null: false
    t.string "action", limit: 50, null: false
    t.text "description"
    t.string "category", limit: 50
    t.boolean "is_system", default: false
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category", "is_active"], name: "index_rbac_permissions_on_category_and_is_active"
    t.index ["category"], name: "index_rbac_permissions_on_category"
    t.index ["resource_type", "action"], name: "index_rbac_permissions_on_resource_type_and_action"
    t.index ["slug"], name: "index_rbac_permissions_on_slug", unique: true
  end

  create_table "rbac_role_permissions", force: :cascade do |t|
    t.integer "rbac_role_id", null: false
    t.integer "rbac_permission_id", null: false
    t.json "constraints", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rbac_permission_id"], name: "index_rbac_role_permissions_on_rbac_permission_id"
    t.index ["rbac_role_id", "rbac_permission_id"], name: "index_role_permissions_on_role_and_permission", unique: true
    t.index ["rbac_role_id"], name: "index_rbac_role_permissions_on_rbac_role_id"
  end

  create_table "rbac_roles", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.string "slug", limit: 100, null: false
    t.string "role_type", limit: 50, null: false
    t.text "description"
    t.boolean "is_system", default: false
    t.boolean "is_active", default: true
    t.integer "priority", default: 0
    t.json "default_permissions", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_rbac_roles_on_name"
    t.index ["role_type", "is_active"], name: "index_rbac_roles_on_role_type_and_is_active"
    t.index ["slug"], name: "index_rbac_roles_on_slug", unique: true
  end

  create_table "referrals", force: :cascade do |t|
    t.integer "referrer_id", null: false
    t.integer "referred_id", null: false
    t.string "status", limit: 50, default: "pending", null: false
    t.datetime "completed_at"
    t.integer "referrer_reward_points", default: 0
    t.integer "referred_reward_points", default: 0
    t.boolean "referrer_reward_paid", default: false
    t.boolean "referred_reward_paid", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["referred_id", "status"], name: "index_referrals_on_referred_and_status"
    t.index ["referred_id"], name: "index_referrals_on_referred_id"
    t.index ["referrer_id", "referred_id"], name: "index_referrals_on_referrer_id_and_referred_id", unique: true
    t.index ["referrer_id", "status"], name: "index_referrals_on_referrer_and_status"
    t.index ["referrer_id"], name: "index_referrals_on_referrer_id"
    t.index ["status"], name: "index_referrals_on_status"
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
    t.string "return_id", limit: 100
    t.integer "order_item_id"
    t.datetime "status_updated_at"
    t.text "status_history"
    t.decimal "resolution_amount", precision: 10, scale: 2
    t.integer "resolved_by_admin_id"
    t.datetime "resolved_at"
    t.string "refund_id", limit: 255
    t.string "refund_status", limit: 50
    t.decimal "refund_amount", precision: 10, scale: 2
    t.string "refund_transaction_id", limit: 255
    t.integer "pickup_address_id"
    t.datetime "pickup_scheduled_at"
    t.datetime "pickup_completed_at"
    t.integer "return_quantity"
    t.string "return_condition", limit: 50
    t.text "return_images"
    t.index ["order_id", "status", "created_at"], name: "index_return_requests_on_order_status_created"
    t.index ["order_id"], name: "index_return_requests_on_order_id"
    t.index ["order_item_id"], name: "index_return_requests_on_order_item_id"
    t.index ["refund_status"], name: "index_return_requests_on_refund_status"
    t.index ["resolved_by_admin_id"], name: "index_return_requests_on_resolved_by_admin_id"
    t.index ["return_id"], name: "index_return_requests_on_return_id", unique: true
    t.index ["user_id"], name: "index_return_requests_on_user_id"
  end

  create_table "review_helpful_votes", force: :cascade do |t|
    t.integer "review_id", null: false
    t.integer "user_id", null: false
    t.boolean "is_helpful", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_helpful"], name: "index_review_helpful_votes_on_is_helpful"
    t.index ["review_id", "user_id"], name: "index_review_helpful_votes_on_review_id_and_user_id", unique: true
    t.index ["review_id"], name: "index_review_helpful_votes_on_review_id"
    t.index ["user_id"], name: "index_review_helpful_votes_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "product_id", null: false
    t.integer "rating"
    t.text "comment"
    t.boolean "verified_purchase"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "title", limit: 255
    t.boolean "is_featured", default: false
    t.text "review_images"
    t.string "moderation_status", limit: 50, default: "pending"
    t.integer "moderated_by_id"
    t.datetime "moderated_at"
    t.text "moderation_notes"
    t.text "supplier_response"
    t.datetime "supplier_response_at"
    t.integer "helpful_count", default: 0
    t.integer "not_helpful_count", default: 0
    t.index ["deleted_at"], name: "index_reviews_on_deleted_at"
    t.index ["is_featured"], name: "index_reviews_on_is_featured"
    t.index ["moderated_by_id"], name: "index_reviews_on_moderated_by_id"
    t.index ["moderation_status"], name: "index_reviews_on_moderation_status"
    t.index ["product_id", "moderation_status", "created_at"], name: "index_reviews_on_product_moderation_created"
    t.index ["product_id"], name: "index_reviews_on_product_id"
    t.index ["user_id", "product_id"], name: "index_reviews_on_user_product"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "search_suggestions", force: :cascade do |t|
    t.string "query", limit: 500, null: false
    t.string "suggestion_type", limit: 50, null: false
    t.integer "reference_id"
    t.string "reference_type", limit: 50
    t.integer "search_count", default: 0
    t.integer "click_count", default: 0
    t.string "display_text", limit: 500
    t.string "image_url", limit: 500
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_active"], name: "index_search_suggestions_on_is_active"
    t.index ["query"], name: "index_search_suggestions_on_query"
    t.index ["search_count"], name: "index_search_suggestions_on_search_count"
    t.index ["suggestion_type"], name: "index_search_suggestions_on_suggestion_type"
  end

  create_table "settings", force: :cascade do |t|
    t.string "key", null: false
    t.text "value"
    t.string "value_type", default: "string"
    t.string "category", default: "general"
    t.text "description"
    t.boolean "is_public", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_settings_on_key", unique: true
  end

  create_table "shipment_tracking_events", force: :cascade do |t|
    t.integer "shipment_id", null: false
    t.string "event_type", limit: 50, null: false
    t.text "event_description"
    t.string "location", limit: 255
    t.string "city", limit: 100
    t.string "state", limit: 100
    t.string "pincode", limit: 20
    t.datetime "event_time", null: false
    t.string "source", limit: 50, default: "provider"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_time"], name: "index_shipment_tracking_events_on_event_time"
    t.index ["shipment_id"], name: "index_shipment_tracking_events_on_shipment_id"
  end

  create_table "shipments", force: :cascade do |t|
    t.string "shipment_id", limit: 100, null: false
    t.integer "order_id", null: false
    t.integer "order_item_id"
    t.integer "shipping_method_id"
    t.string "shipping_provider", limit: 100
    t.string "tracking_number", limit: 255
    t.string "tracking_url", limit: 500
    t.text "from_address", null: false
    t.text "to_address", null: false
    t.string "status", limit: 50, default: "pending", null: false
    t.datetime "status_updated_at"
    t.datetime "shipped_at"
    t.date "estimated_delivery_date"
    t.date "actual_delivery_date"
    t.string "delivered_to", limit: 255
    t.text "delivery_notes"
    t.string "delivery_proof_image_url", limit: 500
    t.decimal "weight_kg", precision: 8, scale: 3
    t.decimal "length_cm", precision: 8, scale: 2
    t.decimal "width_cm", precision: 8, scale: 2
    t.decimal "height_cm", precision: 8, scale: 2
    t.decimal "shipping_charge", precision: 10, scale: 2
    t.decimal "cod_charge", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id", "status", "created_at"], name: "index_shipments_on_order_status_created"
    t.index ["order_id"], name: "index_shipments_on_order_id"
    t.index ["order_item_id"], name: "index_shipments_on_order_item_id"
    t.index ["shipment_id"], name: "index_shipments_on_shipment_id", unique: true
    t.index ["shipping_method_id"], name: "index_shipments_on_shipping_method_id"
    t.index ["shipping_provider"], name: "index_shipments_on_shipping_provider"
    t.index ["status"], name: "index_shipments_on_status"
    t.index ["tracking_number"], name: "index_shipments_on_tracking_number"
  end

  create_table "shipping_methods", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "code", limit: 50, null: false
    t.text "description"
    t.string "provider", limit: 100
    t.string "provider_code", limit: 50
    t.decimal "base_charge", precision: 10, scale: 2, default: "0.0"
    t.decimal "per_kg_charge", precision: 10, scale: 2, default: "0.0"
    t.decimal "free_shipping_above", precision: 10, scale: 2
    t.integer "estimated_days_min"
    t.integer "estimated_days_max"
    t.text "available_pincodes"
    t.text "excluded_pincodes"
    t.text "available_zones", default: "{}"
    t.boolean "is_active", default: true
    t.boolean "is_cod_available", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_shipping_methods_on_code", unique: true
    t.index ["is_active"], name: "index_shipping_methods_on_is_active"
  end

  create_table "supplier_account_users", force: :cascade do |t|
    t.integer "supplier_profile_id", null: false
    t.integer "user_id", null: false
    t.string "role", null: false
    t.string "status", default: "active", null: false
    t.integer "invited_by_id"
    t.datetime "invited_at"
    t.string "invitation_token", limit: 255
    t.datetime "invitation_expires_at"
    t.datetime "accepted_at"
    t.boolean "can_manage_products", default: false
    t.boolean "can_manage_orders", default: false
    t.boolean "can_view_financials", default: false
    t.boolean "can_manage_users", default: false
    t.boolean "can_manage_settings", default: false
    t.boolean "can_view_analytics", default: false
    t.text "custom_permissions", default: "{}"
    t.datetime "last_active_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "rbac_role_id"
    t.datetime "role_assigned_at"
    t.integer "role_assigned_by_id"
    t.index ["invitation_token"], name: "index_supplier_account_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_supplier_account_users_on_invited_by_id"
    t.index ["rbac_role_id"], name: "index_supplier_account_users_on_rbac_role_id"
    t.index ["role"], name: "index_supplier_account_users_on_role"
    t.index ["role_assigned_by_id"], name: "index_supplier_account_users_on_role_assigned_by_id"
    t.index ["status"], name: "index_supplier_account_users_on_status"
    t.index ["supplier_profile_id", "rbac_role_id"], name: "idx_on_supplier_profile_id_rbac_role_id_d3c3595112"
    t.index ["supplier_profile_id", "user_id"], name: "idx_supplier_account_users_unique", unique: true
    t.index ["supplier_profile_id"], name: "index_supplier_account_users_on_supplier_profile_id"
    t.index ["user_id"], name: "index_supplier_account_users_on_user_id"
  end

  create_table "supplier_analytics", force: :cascade do |t|
    t.integer "supplier_profile_id", null: false
    t.date "date", null: false
    t.integer "total_orders", default: 0
    t.decimal "total_revenue", precision: 12, scale: 2, default: "0.0"
    t.integer "total_items_sold", default: 0
    t.integer "products_viewed", default: 0
    t.integer "products_added_to_cart", default: 0
    t.decimal "conversion_rate", precision: 5, scale: 2, default: "0.0"
    t.integer "new_customers", default: 0
    t.integer "returning_customers", default: 0
    t.decimal "average_rating", precision: 3, scale: 2, default: "0.0"
    t.integer "new_reviews_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_supplier_analytics_on_date"
    t.index ["supplier_profile_id", "date"], name: "index_supplier_analytics_on_supplier_profile_id_and_date", unique: true
    t.index ["supplier_profile_id"], name: "index_supplier_analytics_on_supplier_profile_id"
  end

  create_table "supplier_payments", force: :cascade do |t|
    t.string "payment_id", limit: 100, null: false
    t.integer "supplier_profile_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "currency", limit: 10, default: "INR"
    t.decimal "commission_deducted", precision: 10, scale: 2, default: "0.0"
    t.decimal "net_amount", precision: 10, scale: 2, null: false
    t.string "payment_method", limit: 50, null: false
    t.string "bank_account_number", limit: 50
    t.string "bank_ifsc_code", limit: 20
    t.string "transaction_reference", limit: 255
    t.string "status", limit: 50, default: "pending", null: false
    t.text "failure_reason"
    t.date "period_start_date", null: false
    t.date "period_end_date", null: false
    t.integer "order_items_count", default: 0
    t.integer "processed_by_id"
    t.datetime "processed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_id"], name: "index_supplier_payments_on_payment_id", unique: true
    t.index ["period_start_date", "period_end_date"], name: "idx_on_period_start_date_period_end_date_e7f071a020"
    t.index ["processed_by_id"], name: "index_supplier_payments_on_processed_by_id"
    t.index ["status"], name: "index_supplier_payments_on_status"
    t.index ["supplier_profile_id"], name: "index_supplier_payments_on_supplier_profile_id"
  end

  create_table "supplier_profiles", force: :cascade do |t|
    t.string "company_name"
    t.string "gst_number"
    t.text "description"
    t.string "website_url"
    t.boolean "verified"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "migration_status", default: "pending"
    t.integer "owner_id"
    t.string "company_registration_number", limit: 100
    t.string "pan_number", limit: 20
    t.string "cin_number", limit: 50
    t.string "business_type", limit: 50
    t.string "business_category", limit: 100
    t.text "warehouse_addresses", default: "[]"
    t.string "contact_email"
    t.string "contact_phone", limit: 20
    t.string "support_email"
    t.string "support_phone", limit: 20
    t.text "verification_documents", default: "[]"
    t.string "supplier_tier", limit: 50, default: "basic"
    t.datetime "tier_upgraded_at"
    t.integer "max_users", default: 1
    t.boolean "allow_invites", default: false
    t.string "invite_code", limit: 50
    t.integer "active_products_count", default: 0
    t.integer "total_reviews_count", default: 0
    t.string "bank_branch"
    t.string "account_holder_name"
    t.string "upi_id"
    t.string "payment_cycle", limit: 50, default: "weekly"
    t.integer "handling_time_days", default: 1
    t.text "shipping_zones", default: "{}"
    t.decimal "free_shipping_above", precision: 10, scale: 2
    t.boolean "is_active", default: true
    t.boolean "is_suspended", default: false
    t.text "suspended_reason"
    t.datetime "suspended_at"
    t.index ["invite_code"], name: "index_supplier_profiles_on_invite_code", unique: true
    t.index ["is_active"], name: "index_supplier_profiles_on_is_active"
    t.index ["migration_status"], name: "index_supplier_profiles_on_migration_status"
    t.index ["owner_id"], name: "index_supplier_profiles_on_owner_id"
    t.index ["supplier_tier"], name: "index_supplier_profiles_on_supplier_tier"
    t.index ["user_id"], name: "index_supplier_profiles_on_user_id"
  end

# Could not dump table "supplier_profiles_backup" because of following StandardError
#   Unknown type 'NUM' for column 'verified'

# Could not dump table "suppliers_backup" because of following StandardError
#   Unknown type 'NUM' for column 'created_at'

  create_table "support_ticket_messages", force: :cascade do |t|
    t.integer "support_ticket_id", null: false
    t.text "message", null: false
    t.string "sender_type", limit: 50, null: false
    t.integer "sender_id", null: false
    t.text "attachments", default: "[]"
    t.boolean "is_internal", default: false
    t.boolean "is_read", default: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_support_ticket_messages_on_created_at"
    t.index ["sender_type", "sender_id"], name: "index_support_ticket_messages_on_sender_type_and_sender_id"
    t.index ["support_ticket_id", "created_at"], name: "index_support_messages_on_ticket_and_created"
    t.index ["support_ticket_id"], name: "index_support_ticket_messages_on_support_ticket_id"
  end

  create_table "support_tickets", force: :cascade do |t|
    t.string "ticket_id", limit: 50, null: false
    t.integer "user_id", null: false
    t.string "subject", limit: 255, null: false
    t.text "description", null: false
    t.string "category", limit: 50, null: false
    t.string "status", limit: 50, default: "open", null: false
    t.string "priority", limit: 50, default: "medium"
    t.integer "assigned_to_id"
    t.datetime "assigned_at"
    t.text "resolution"
    t.integer "resolved_by_id"
    t.datetime "resolved_at"
    t.integer "order_id"
    t.integer "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "closed_at"
    t.index ["assigned_to_id", "status"], name: "index_support_tickets_on_assigned_and_status"
    t.index ["assigned_to_id"], name: "index_support_tickets_on_assigned_to_id"
    t.index ["created_at"], name: "index_support_tickets_on_created_at"
    t.index ["order_id"], name: "index_support_tickets_on_order_id"
    t.index ["product_id"], name: "index_support_tickets_on_product_id"
    t.index ["resolved_by_id"], name: "index_support_tickets_on_resolved_by_id"
    t.index ["status"], name: "index_support_tickets_on_status"
    t.index ["ticket_id"], name: "index_support_tickets_on_ticket_id", unique: true
    t.index ["user_id", "status"], name: "index_support_tickets_on_user_and_status"
    t.index ["user_id"], name: "index_support_tickets_on_user_id"
  end

  create_table "system_configurations", force: :cascade do |t|
    t.string "key", null: false
    t.text "value"
    t.string "value_type", default: "string", null: false
    t.string "category", default: "general"
    t.text "description"
    t.boolean "is_active", default: true, null: false
    t.string "created_by_type"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_system_configurations_on_category"
    t.index ["created_by_type", "created_by_id"], name: "index_system_configurations_on_created_by"
    t.index ["is_active"], name: "index_system_configurations_on_is_active"
    t.index ["key"], name: "index_system_configurations_on_key", unique: true
  end

  create_table "trending_products", force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "views_24h", default: 0
    t.integer "orders_24h", default: 0
    t.decimal "revenue_24h", precision: 12, scale: 2, default: "0.0"
    t.decimal "trend_score", precision: 10, scale: 2, default: "0.0"
    t.integer "category_id"
    t.integer "rank_in_category"
    t.datetime "calculated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calculated_at"], name: "index_trending_products_on_calculated_at"
    t.index ["category_id"], name: "index_trending_products_on_category_id"
    t.index ["product_id", "calculated_at"], name: "index_trending_products_on_product_id_and_calculated_at", unique: true
    t.index ["product_id"], name: "index_trending_products_on_product_id"
    t.index ["trend_score"], name: "index_trending_products_on_trend_score"
  end

  create_table "user_searches", force: :cascade do |t|
    t.integer "user_id"
    t.string "session_id", limit: 255
    t.string "search_query", limit: 500, null: false
    t.text "filters", default: "{}"
    t.integer "results_count"
    t.string "source", limit: 50
    t.datetime "searched_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["search_query"], name: "index_user_searches_on_search_query"
    t.index ["searched_at"], name: "index_user_searches_on_searched_at"
    t.index ["session_id"], name: "index_user_searches_on_session_id"
    t.index ["user_id", "searched_at"], name: "index_user_searches_on_user_and_searched_at"
    t.index ["user_id"], name: "index_user_searches_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "phone_number"
    t.string "password_digest"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "email_verified"
    t.string "temp_password_digest"
    t.datetime "temp_password_expires_at"
    t.boolean "password_reset_required", default: false
    t.datetime "deleted_at"
    t.string "alternate_phone"
    t.date "date_of_birth"
    t.string "gender"
    t.string "profile_image_url", limit: 500
    t.string "referral_code", limit: 50
    t.integer "referred_by_id"
    t.integer "loyalty_points", default: 0
    t.integer "total_loyalty_points_earned", default: 0
    t.string "preferred_language", limit: 10, default: "en"
    t.string "preferred_currency", limit: 10, default: "INR"
    t.string "timezone", limit: 50, default: "Asia/Kolkata"
    t.json "notification_preferences", default: {"email"=>true, "sms"=>true, "push"=>true}
    t.boolean "is_active", default: true
    t.boolean "is_blocked", default: false
    t.text "blocked_reason"
    t.datetime "blocked_at"
    t.datetime "last_login_at"
    t.datetime "last_active_at"
    t.string "google_id"
    t.string "facebook_id"
    t.string "apple_id"
    t.datetime "password_changed_at"
    t.integer "orders_count", default: 0, null: false
    t.string "invitation_token"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_expires_at"
    t.integer "invited_by_id"
    t.datetime "invitation_accepted_at"
    t.string "invitation_role"
    t.string "invitation_status"
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_status"], name: "index_users_on_invitation_status"
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["is_active"], name: "index_users_on_is_active"
    t.index ["last_active_at"], name: "index_users_on_last_active_at"
    t.index ["notification_preferences"], name: "index_users_on_notification_preferences"
    t.index ["phone_number"], name: "index_users_on_phone_number", unique: true
    t.index ["referral_code"], name: "index_users_on_referral_code", unique: true
    t.index ["referred_by_id"], name: "index_users_on_referred_by_id"
    t.check_constraint "gender IN ('male', 'female', 'other', 'prefer_not_to_say') OR gender IS NULL", name: "check_users_gender"
    t.check_constraint "role IN ('customer', 'premium_customer', 'vip_customer', 'supplier', 'super_admin', 'product_admin', 'order_admin', 'support_admin')", name: "check_users_role"
  end

# Could not dump table "users_backup" because of following StandardError
#   Unknown type 'NUM' for column 'created_at'

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object", limit: 1073741823
    t.text "object_changes", limit: 1073741823
    t.string "ip_address"
    t.string "user_agent"
    t.string "transaction_id"
    t.datetime "created_at", null: false
    t.index ["created_at"], name: "index_versions_on_created_at"
    t.index ["event"], name: "index_versions_on_event"
    t.index ["item_type", "item_id", "created_at"], name: "index_versions_on_item_type_and_item_id_and_created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["transaction_id"], name: "index_versions_on_transaction_id"
    t.index ["whodunnit"], name: "index_versions_on_whodunnit"
  end

  create_table "warehouse_inventory", force: :cascade do |t|
    t.integer "warehouse_id", null: false
    t.integer "product_variant_id", null: false
    t.integer "stock_quantity", default: 0, null: false
    t.integer "reserved_quantity", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_variant_id"], name: "index_warehouse_inventory_on_product_variant_id"
    t.index ["warehouse_id", "product_variant_id"], name: "idx_on_warehouse_id_product_variant_id_b0560e3f90", unique: true
    t.index ["warehouse_id"], name: "index_warehouse_inventory_on_warehouse_id"
  end

  create_table "warehouses", force: :cascade do |t|
    t.integer "supplier_profile_id", null: false
    t.string "name", limit: 255, null: false
    t.string "code", limit: 50, null: false
    t.text "address", null: false
    t.string "city", limit: 100
    t.string "state", limit: 100
    t.string "pincode", limit: 20
    t.string "country", limit: 100, default: "India"
    t.string "contact_person", limit: 255
    t.string "contact_phone", limit: 20
    t.string "contact_email", limit: 255
    t.boolean "is_active", default: true
    t.boolean "is_primary", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_active"], name: "index_warehouses_on_is_active"
    t.index ["supplier_profile_id", "code"], name: "index_warehouses_on_supplier_profile_id_and_code", unique: true
    t.index ["supplier_profile_id"], name: "index_warehouses_on_supplier_profile_id"
  end

  create_table "wishlist_items", force: :cascade do |t|
    t.integer "wishlist_id", null: false
    t.integer "product_variant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.text "notes"
    t.integer "priority", default: 0
    t.decimal "price_when_added", precision: 10, scale: 2
    t.decimal "current_price", precision: 10, scale: 2
    t.boolean "price_drop_notified", default: false
    t.index ["deleted_at"], name: "index_wishlist_items_on_deleted_at"
    t.index ["product_variant_id"], name: "index_wishlist_items_on_product_variant_id"
    t.index ["wishlist_id", "created_at"], name: "index_wishlist_items_on_wishlist_created"
    t.index ["wishlist_id"], name: "index_wishlist_items_on_wishlist_id"
  end

  create_table "wishlists", force: :cascade do |t|
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "name", limit: 255
    t.text "description"
    t.boolean "is_public", default: false
    t.boolean "is_default", default: false
    t.string "share_token", limit: 255
    t.boolean "share_enabled", default: false
    t.index ["deleted_at"], name: "index_wishlists_on_deleted_at"
    t.index ["share_token"], name: "index_wishlists_on_share_token", unique: true
    t.index ["user_id"], name: "index_wishlists_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "users"
  add_foreign_key "admin_activities", "admins"
  add_foreign_key "admin_role_assignments", "admins"
  add_foreign_key "admin_role_assignments", "admins", column: "assigned_by_id"
  add_foreign_key "admin_role_assignments", "rbac_roles"
  add_foreign_key "admins", "admins", column: "invited_by_id"
  add_foreign_key "attribute_values", "attribute_types"
  add_foreign_key "audit_logs", "users"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "product_variants"
  add_foreign_key "carts", "users"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "coupon_usages", "coupons"
  add_foreign_key "coupon_usages", "orders"
  add_foreign_key "coupon_usages", "users"
  add_foreign_key "coupons", "admins", column: "created_by_id"
  add_foreign_key "inventory_transactions", "product_variants"
  add_foreign_key "inventory_transactions", "supplier_profiles"
  add_foreign_key "inventory_transactions", "users", column: "performed_by_id"
  add_foreign_key "loyalty_points_transactions", "users"
  add_foreign_key "notification_preferences", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "product_variants"
  add_foreign_key "order_items", "supplier_profiles"
  add_foreign_key "orders", "addresses", column: "billing_address_id"
  add_foreign_key "orders", "addresses", column: "shipping_address_id"
  add_foreign_key "orders", "users"
  add_foreign_key "payment_refunds", "order_items"
  add_foreign_key "payment_refunds", "orders"
  add_foreign_key "payment_refunds", "payments"
  add_foreign_key "payment_refunds", "users", column: "processed_by_id"
  add_foreign_key "payment_transactions", "orders"
  add_foreign_key "payment_transactions", "payments"
  add_foreign_key "payments", "orders"
  add_foreign_key "payments", "users"
  add_foreign_key "product_attributes", "attribute_values"
  add_foreign_key "product_attributes", "products"
  add_foreign_key "product_images", "product_variants"
  add_foreign_key "product_variant_attributes", "attribute_values"
  add_foreign_key "product_variant_attributes", "product_variants"
  add_foreign_key "product_variants", "products"
  add_foreign_key "product_views", "product_variants"
  add_foreign_key "product_views", "products"
  add_foreign_key "product_views", "users"
  add_foreign_key "products", "brands"
  add_foreign_key "products", "categories"
  add_foreign_key "products", "supplier_profiles"
  add_foreign_key "products", "users", column: "verified_by_admin_id"
  add_foreign_key "promotions", "admins", column: "created_by_id"
  add_foreign_key "rbac_role_permissions", "rbac_permissions"
  add_foreign_key "rbac_role_permissions", "rbac_roles"
  add_foreign_key "referrals", "users", column: "referred_id"
  add_foreign_key "referrals", "users", column: "referrer_id"
  add_foreign_key "return_items", "order_items"
  add_foreign_key "return_items", "return_requests"
  add_foreign_key "return_media", "return_items"
  add_foreign_key "return_requests", "orders"
  add_foreign_key "return_requests", "users"
  add_foreign_key "review_helpful_votes", "reviews"
  add_foreign_key "review_helpful_votes", "users"
  add_foreign_key "reviews", "products"
  add_foreign_key "reviews", "users"
  add_foreign_key "shipment_tracking_events", "shipments"
  add_foreign_key "shipments", "order_items"
  add_foreign_key "shipments", "orders"
  add_foreign_key "shipments", "shipping_methods"
  add_foreign_key "supplier_account_users", "rbac_roles"
  add_foreign_key "supplier_account_users", "supplier_profiles"
  add_foreign_key "supplier_account_users", "users"
  add_foreign_key "supplier_account_users", "users", column: "invited_by_id"
  add_foreign_key "supplier_account_users", "users", column: "role_assigned_by_id"
  add_foreign_key "supplier_analytics", "supplier_profiles"
  add_foreign_key "supplier_payments", "admins", column: "processed_by_id"
  add_foreign_key "supplier_payments", "supplier_profiles"
  add_foreign_key "supplier_profiles", "users"
  add_foreign_key "supplier_profiles", "users", column: "owner_id"
  add_foreign_key "support_ticket_messages", "support_tickets"
  add_foreign_key "support_tickets", "admins", column: "assigned_to_id"
  add_foreign_key "support_tickets", "admins", column: "resolved_by_id"
  add_foreign_key "support_tickets", "orders"
  add_foreign_key "support_tickets", "products"
  add_foreign_key "support_tickets", "users"
  add_foreign_key "trending_products", "categories"
  add_foreign_key "trending_products", "products"
  add_foreign_key "user_searches", "users"
  add_foreign_key "users", "users", column: "invited_by_id"
  add_foreign_key "users", "users", column: "referred_by_id"
  add_foreign_key "warehouse_inventory", "product_variants"
  add_foreign_key "warehouse_inventory", "warehouses"
  add_foreign_key "warehouses", "supplier_profiles"
  add_foreign_key "wishlist_items", "product_variants"
  add_foreign_key "wishlist_items", "wishlists"
  add_foreign_key "wishlists", "users"
end
