# API Specification

This document defines the RESTful API for the e-commerce platform. All endpoints are prefixed with `/api/v1`.

---

## 1. Authentication

### `POST /signup`

*   **Use Case:** Allows a new user (customer or supplier) to register.
*   **Request Payload:**
    ```json
    {
      "user": {
        "first_name": "John",
        "last_name": "Doe",
        "email": "john.doe@example.com",
        "phone_number": "1234567890",
        "password": "securepassword123",
        "password_confirmation": "securepassword123",
        "role": "customer" // or "supplier"
      }
    }
    ```
*   **Response (Success 201):**
    ```json
    {
      "message": "User created successfully",
      "user": {
        "id": 1,
        "email": "john.doe@example.com",
        "role": "customer"
      },
      "token": "ey..."
    }
    ```
*   **Authorization:** Public.

### `POST /login`

*   **Use Case:** Authenticates an existing user and returns a JWT.
*   **Request Payload:**
    ```json
    {
      "email": "john.doe@example.com",
      "password": "securepassword123"
    }
    ```
*   **Response (Success 200):**
    ```json
    {
      "message": "Logged in successfully",
      "token": "ey..."
    }
    ```
*   **Authorization:** Public.

---

## 2. Supplier Profile

### `GET /supplier/profile`

*   **Use Case:** Fetches the profile for the currently authenticated supplier.
*   **Authorization:** Supplier only.
*   **Response (Success 200):**
    ```json
    {
      "supplier_profile": {
        "company_name": "Fashion Supplies Inc.",
        "gst_number": "ABCDE12345",
        "description": "...",
        "website_url": "https://fashionsupplies.com",
        "verified": true
      }
    }
    ```

### `PUT /supplier/profile`

*   **Use Case:** Updates the profile for the currently authenticated supplier.
*   **Authorization:** Supplier only.
*   **Request Payload:**
    ```json
    {
      "supplier_profile": {
        "company_name": "New Fashion Supplies Inc.",
        "website_url": "https://newfashionsupplies.com"
      }
    }
    ```
*   **Response (Success 200):** (Returns the updated profile)

---

## 3. Product Discovery (for Customers)

### `GET /products/search`

*   **Use Case:** The main endpoint for customers to search and filter for products.
*   **Authorization:** Public.
*   **Query Parameters:**
    *   `query`: (string) e.g., "blue t-shirt"
    *   `category_id`: (integer)
    *   `brand_id`: (integer)
    *   `attributes[color]`: (string) e.g., "Blue"
    *   `attributes[size]`: (string) e.g., "M"
    *   `price[min]`: (float)
    *   `price[max]`: (float)
    *   `page`: (integer)
    *   `per_page`: (integer)
*   **Response (Success 200):**
    ```json
    {
      "products": [ /* array of product summary objects */ ],
      "facets": { /* object with available filters and counts */ },
      "pagination": { /* pagination details */ }
    }
    ```

### `GET /products/:id`

*   **Use Case:** Fetches all details for a single product.
*   **Authorization:** Public.
*   **Response (Success 200):** (A detailed product object with all variants, images, reviews, etc.)

---

## 4. Product Management (for Suppliers)

### `GET /supplier/products`

*   **Use Case:** Lists all products belonging to the authenticated supplier.
*   **Authorization:** Supplier only.
*   **Response (Success 200):** (An array of the supplier's products with status).

### `POST /supplier/products`

*   **Use Case:** Creates a new product.
*   **Authorization:** Supplier only.
*   **Request Payload:** (A complex object containing product details, variants, attributes, and image references).
*   **Response (Success 201):** (The newly created product object).

### `PUT /supplier/products/:id`

*   **Use Case:** Updates an existing product.
*   **Authorization:** Supplier only.
*   **Response (Success 200):** (The updated product object).

---

---

## 5. Cart (for Customers)

### `GET /cart`
*   **Use Case:** Fetches the contents of the authenticated user's shopping cart.
*   **Authorization:** Customer only.
*   **Response (Success 200):**
    ```json
    {
      "cart_items": [
        {
          "cart_item_id": 1,
          "quantity": 2,
          "product_variant": {
            "variant_id": 456,
            "product_name": "Men's Cotton T-Shirt",
            "sku": "CBT-M-BLUE",
            "price": 25.99,
            "image_url": "http://path.to/image_blue.jpg"
          }
        }
      ],
      "total_price": 51.98
    }
    ```

### `POST /cart/items`
*   **Use Case:** Adds a new item to the cart.
*   **Authorization:** Customer only.
*   **Request Payload:**
    ```json
    {
      "product_variant_id": 457,
      "quantity": 1
    }
    ```
*   **Response (Success 201):** (Returns the full cart contents)

### `PUT /cart/items/:id`
*   **Use Case:** Updates the quantity of an item in the cart.
*   **Authorization:** Customer only.
*   **Request Payload:** `{"quantity": 3}`
*   **Response (Success 200):** (Returns the full cart contents)

### `DELETE /cart/items/:id`
*   **Use Case:** Removes an item from the cart.
*   **Authorization:** Customer only.
*   **Response (Success 204):** No content.

---

## 6. Checkout & Orders (for Customers)

### `POST /orders`
*   **Use Case:** Creates a new order from the user's cart. This is the final step in the checkout process.
*   **Authorization:** Customer only.
*   **Request Payload:**
    ```json
    {
      "shipping_address_id": 1,
      "billing_address_id": 1,
      "payment_token": "tok_visa" // From payment gateway
    }
    ```
*   **Response (Success 201):** (The newly created Order object)

### `GET /my-orders`
*   **Use Case:** Lists all past and current orders for the authenticated customer.
*   **Authorization:** Customer only.
*   **Response (Success 200):** (An array of Order summary objects)

### `GET /my-orders/:id`
*   **Use Case:** Fetches the full details of a single order.
*   **Authorization:** Customer only.
*   **Response (Success 200):** (A detailed Order object with all order items and tracking info)

---

## 7. Order Management (for Suppliers)

### `GET /supplier/orders`
*   **Use Case:** Lists all orders containing products from the authenticated supplier.
*   **Authorization:** Supplier only.
*   **Response (Success 200):** (An array of OrderItem objects relevant to the supplier)

### `PUT /supplier/orders/:item_id/ship`
*   **Use Case:** Marks a specific order item as shipped.
*   **Authorization:** Supplier only.
*   **Request Payload:** `{"tracking_number": "1Z9999W99999999999"}`
*   **Response (Success 200):** (The updated OrderItem object)

---

## 8. Returns

### `POST /returns`
*   **Use Case:** A customer initiates a return request for one or more items from an order.
*   **Authorization:** Customer only.
*   **Request Payload:**
    ```json
    {
      "order_id": 123,
      "resolution_type": "refund",
      "items": [
        {
          "order_item_id": 456,
          "quantity": 1,
          "reason": "Doesn't fit"
        }
      ],
      "media": [
        { "file_key": "s3_key_for_image.jpg", "media_type": "image" }
      ]
    }
    ```
*   **Response (Success 201):** (The newly created ReturnRequest object)

### `GET /my-returns`
*   **Use Case:** Lists all return requests initiated by the authenticated customer.
*   **Authorization:** Customer only.
*   **Response (Success 200):** (An array of ReturnRequest summary objects)

---

## 9. Admin Actions

*Note: Most admin actions will be performed through the `rails_admin` UI, which uses standard Rails controller actions. However, some key actions might be exposed via the API for specific frontend admin panels or automated scripts.*

### `POST /admin/products/:id/verify`
*   **Use Case:** An admin verifies a pending product, making it active.
*   **Authorization:** `product_admin` or `super_admin` only.
*   **Response (Success 200):** (The updated Product object with status "active")

### `POST /admin/products/:id/reject`
*   **Use Case:** An admin rejects a pending product.
*   **Authorization:** `product_admin` or `super_admin` only.
*   **Request Payload:** `{"reason": "Images are low quality"}`
*   **Response (Success 200):** (The updated Product object with status "rejected")

### `GET /admin/users`
*   **Use Case:** An admin lists all users in the system.
*   **Authorization:** `super_admin` only.
*   **Response (Success 200):** (An array of User objects)

---

## 10. Wishlist (for Customers)

### `GET /wishlist`
*   **Use Case:** Fetches the contents of the authenticated user's wishlist.
*   **Authorization:** Customer only.
*   **Response (Success 200):**
    ```json
    {
      "wishlist_items": [
        {
          "wishlist_item_id": 1,
          "product_variant": {
            "variant_id": 456,
            "product_name": "Men's Cotton T-Shirt",
            "sku": "CBT-M-BLUE",
            "price": 25.99,
            "image_url": "http://path.to/image_blue.jpg"
          }
        }
      ]
    }
    ```

### `POST /wishlist/items`
*   **Use Case:** Adds a product variant to the user's wishlist.
*   **Authorization:** Customer only.
*   **Request Payload:**
    ```json
    {
      "product_variant_id": 457
    }
    ```
*   **Response (Success 201):** (Returns the full wishlist contents)

### `DELETE /wishlist/items/:product_variant_id`
*   **Use Case:** Removes a product variant from the wishlist.
*   **Authorization:** Customer only.
*   **Response (Success 204):** No content.

This expanded specification provides a comprehensive guide for the development of all planned features.