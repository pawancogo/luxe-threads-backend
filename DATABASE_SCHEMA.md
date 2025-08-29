# Definitive & Optimized Database Schema

This document contains the final, approved database schema for the e-commerce platform. This schema is the single source of truth for all data structures in the PostgreSQL database.

```mermaid
erDiagram
    User {
        int id PK
        string first_name
        string last_name
        string email UK
        string phone_number UK
        string password_digest
        string role "enum: customer, supplier, super_admin, product_admin, order_admin"
        datetime created_at
        datetime updated_at
    }

    SupplierProfile {
        int id PK
        int user_id FK
        string company_name
        string gst_number
        text description
        string website_url
        boolean verified "Default: false"
        datetime created_at
        datetime updated_at
    }

    Product {
        int id PK
        int supplier_profile_id FK
        int category_id FK
        int brand_id FK
        string name
        text description
        string status "enum: pending, active, rejected, archived"
        int verified_by_admin_id FK "nullable, user.id"
        datetime verified_at "nullable"
        datetime created_at
        datetime updated_at
    }

    ProductVariant {
        int id PK
        int product_id FK
        string sku UK
        decimal price
        decimal discounted_price
        int stock_quantity
        float weight_kg
        datetime created_at
        datetime updated_at
    }

    ProductImage {
        int id PK
        int product_variant_id FK
        string image_url
        string alt_text
        int display_order
    }

    Category {
        int id PK
        int parent_category_id FK "nullable"
        string name
        datetime created_at
        datetime updated_at
    }

    Brand {
        int id PK
        string name
        string logo_url
        datetime created_at
        datetime updated_at
    }

    AttributeType {
        int id PK
        string name "e.g., 'Color', 'Size'"
        datetime created_at
        datetime updated_at
    }

    AttributeValue {
        int id PK
        int attribute_type_id FK
        string value "e.g., 'Red', 'M'"
        datetime created_at
        datetime updated_at
    }

    ProductVariantAttribute {
        int product_variant_id FK
        int attribute_value_id FK
    }

    Order {
        int id PK
        int user_id FK
        int shipping_address_id FK
        int billing_address_id FK
        string status "pending, paid, packed, shipped, delivered, cancelled"
        string payment_status "pending, complete, failed"
        string shipping_method
        decimal total_amount
        datetime created_at
        datetime updated_at
    }

    OrderItem {
        int id PK
        int order_id FK
        int product_variant_id FK
        int quantity
        decimal price_at_purchase
        datetime created_at
        datetime updated_at
    }

    Address {
        int id PK
        int user_id FK
        string address_type "shipping, billing"
        string full_name
        string phone_number
        string line1
        string line2
        string city
        string state
        string postal_code
        string country
        datetime created_at
        datetime updated_at
    }

    Review {
        int id PK
        int user_id FK
        int product_id FK
        int rating "1-5"
        text comment
        boolean verified_purchase
        datetime created_at
        datetime updated_at
    }

    ReturnRequest {
        int id PK
        int user_id FK
        int order_id FK
        string status "enum: requested, approved, rejected, shipped, received, completed"
        string resolution_type "enum: refund, replacement"
        datetime created_at
        datetime updated_at
    }

    ReturnItem {
        int id PK
        int return_request_id FK
        int order_item_id FK
        int quantity
        text reason
        datetime created_at
        datetime updated_at
    }

    ReturnMedia {
        int id PK
        int return_item_id FK
        string media_url
        string media_type "enum: image, video"
        datetime created_at
        datetime updated_at
    }

    User ||--o{ SupplierProfile : ""
    SupplierProfile ||--|{ Product : ""
    Category ||--o{ Product : ""
    Brand ||--o{ Product : ""
    Product ||--|{ ProductVariant : ""
    ProductVariant ||--|{ ProductVariantAttribute : ""
    AttributeValue }|--|{ ProductVariantAttribute : ""
    AttributeType ||--|{ AttributeValue : ""
    ProductVariant ||--|{ ProductImage: ""
    User ||--|{ Order : ""
    Order ||--|{ OrderItem : ""
    ProductVariant ||--o{ OrderItem : ""
    User ||--|{ Address : ""
    Address }|..|{ Order : "shipping"
    Address }|..|{ Order : "billing"
    User ||--|{ Review : ""
    Product ||--o{ Review : ""
    User ||--o{ Product : "verifies"
    Order }|..|{ ReturnRequest : ""
    User }|..|{ ReturnRequest : ""
    ReturnRequest ||--|{ ReturnItem : ""
    OrderItem }|..|{ ReturnItem : ""
    ReturnItem ||--|{ ReturnMedia : ""

    Wishlist {
        int id PK
        int user_id FK
        datetime created_at
        datetime updated_at
    }

    WishlistItem {
        int id PK
        int wishlist_id FK
        int product_variant_id FK
        datetime created_at
    }

    User ||--o{ Wishlist : "has one"
    Wishlist ||--|{ WishlistItem : "contains"
    ProductVariant ||--o{ WishlistItem : "can be in"