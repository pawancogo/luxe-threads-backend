# Database Schema Explanation

This document provides a detailed explanation of the database schema for the e-commerce platform.

## User Management

### `User`

*   **Purpose:** Stores information about all users of the platform, including customers, suppliers, and administrators.
*   **Columns:**
    *   `id`: Primary key.
    *   `first_name`, `last_name`: User's name.
    *   `email`, `phone_number`: Unique contact information for the user.
    *   `password_digest`: Hashed password for authentication.
    *   `role`: Defines the user's permissions. Can be `customer`, `supplier`, `super_admin`, `product_admin`, or `order_admin`.
*   **Relationships:**
    *   A `User` with the `supplier` role has one `SupplierProfile`.
    *   A `User` can have many `Order`s, `Address`es, `Review`s, and `Wishlist`s.

### `SupplierProfile`

*   **Purpose:** Stores additional information for users who are suppliers.
*   **Columns:**
    *   `user_id`: Foreign key linking to the `User` table.
    *   `company_name`, `gst_number`: Business details.
    *   `description`, `website_url`: More information about the supplier.
    *   `verified`: A boolean flag indicating if the supplier has been verified by an admin.
*   **Relationships:**
    *   Belongs to one `User`.
    *   Has many `Product`s.

## Product Catalog

### `Product`

*   **Purpose:** The core table for products. It holds information that is common to all variations of a product.
*   **Columns:**
    *   `supplier_profile_id`: Links the product to the supplier who listed it.
    *   `category_id`, `brand_id`: Classifies the product.
    *   `name`, `description`: The product's title and detailed description.
    *   `status`: The current state of the product listing (`pending`, `active`, `rejected`, `archived`).
    *   `verified_by_admin_id`, `verified_at`: Records which admin verified the product and when.
*   **Relationships:**
    *   Belongs to a `SupplierProfile`, `Category`, and `Brand`.
    *   Has many `ProductVariant`s and `Review`s.

### `ProductVariant`

*   **Purpose:** Represents a specific version of a product that a customer can buy. For example, a T-shirt (`Product`) might have variants for different sizes and colors.
*   **Columns:**
    *   `product_id`: Links to the parent `Product`.
    *   `sku`: A unique stock-keeping unit for this specific variant.
    *   `price`, `discounted_price`: Pricing information.
    *   `stock_quantity`: How many of this variant are in stock.
    *   `weight_kg`: The weight of the product variant, used for shipping calculations.
*   **Relationships:**
    *   Belongs to one `Product`.
    *   Has many `ProductImage`s.
    *   Is linked to its specific attributes (like 'Color' and 'Size') through `ProductVariantAttribute`.
    *   Can be in many `OrderItem`s and `WishlistItem`s.

### `ProductImage`

*   **Purpose:** Stores images for each product variant.
*   **Columns:**
    *   `product_variant_id`: Links to the `ProductVariant`.
    *   `image_url`, `alt_text`: The image path and a description for accessibility.
    *   `display_order`: Determines the order in which images are shown.
*   **Relationships:**
    *   Belongs to one `ProductVariant`.

### `Category`

*   **Purpose:** Organizes products into a hierarchy (e.g., "Clothing" > "Shirts").
*   **Columns:**
    *   `parent_category_id`: Allows for nesting categories. If this is null, it's a top-level category.
    *   `name`: The name of the category.
*   **Relationships:**
    *   Can have many `Product`s.
    *   Can have a parent `Category`.

### `Brand`

*   **Purpose:** Stores information about product brands.
*   **Columns:**
    *   `name`, `logo_url`: The brand's name and logo.
*   **Relationships:**
    *   Has many `Product`s.

### Attributes (`AttributeType`, `AttributeValue`, `ProductVariantAttribute`)

*   **Purpose:** A flexible system to define product variations.
*   `AttributeType`: Defines the type of attribute (e.g., 'Color', 'Size').
*   `AttributeValue`: Defines a specific value for a type (e.g., 'Red', 'M').
*   `ProductVariantAttribute`: A join table that links a `ProductVariant` to its `AttributeValue`s. This is how the system knows a variant is "Red" and "M".

## Order Management

### `Order`

*   **Purpose:** Represents a customer's order.
*   **Columns:**
    *   `user_id`: The customer who placed the order.
    *   `shipping_address_id`, `billing_address_id`: Links to the addresses for the order.
    *   `status`: The overall status of the order (`pending`, `paid`, `shipped`, etc.).
    *   `payment_status`: The status of the payment (`pending`, `complete`, `failed`).
    *   `total_amount`: The total cost of the order.
*   **Relationships:**
    *   Belongs to a `User`.
    *   Has many `OrderItem`s.

### `OrderItem`

*   **Purpose:** Represents a single line item within an order.
*   **Columns:**
    *   `order_id`: Links to the parent `Order`.
    *   `product_variant_id`: The specific `ProductVariant` that was purchased.
    *   `quantity`: The number of units purchased.
    *   `price_at_purchase`: The price of the variant when the order was placed.
*   **Relationships:**
    *   Belongs to an `Order` and a `ProductVariant`.

## Customer Data

### `Address`

*   **Purpose:** Stores shipping and billing addresses for users.
*   **Columns:**
    *   `user_id`: The user who owns this address.
    *   `address_type`: Whether it's a `shipping` or `billing` address.
*   **Relationships:**
    *   Belongs to a `User`.

### `Review`

*   **Purpose:** Stores customer reviews for products.
*   **Columns:**
    *   `user_id`, `product_id`: The user who wrote the review and the product being reviewed.
    *   `rating`: A score from 1 to 5.
    *   `comment`: The text of the review.
*   **Relationships:**
    *   Belongs to a `User` and a `Product`.

### `Wishlist` & `WishlistItem`

*   **Purpose:** Allows users to save products they want to buy later.
*   `Wishlist`: The container for a user's wishlist items.
*   `WishlistItem`: A specific `ProductVariant` that a user has added to their wishlist.