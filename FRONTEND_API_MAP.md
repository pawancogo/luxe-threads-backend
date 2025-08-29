# Frontend API Endpoint Mapping

This document maps frontend pages/components to the specific API endpoints they will consume. This serves as a guide for both frontend and backend developers.

---

## 1. User Frontend Application

### **Page: Home**
*   **Component:** Featured Products
*   **Endpoint:** `GET /products/search` (with parameters like `is_featured=true`)

### **Page: Product Listing (Category/Search Results)**
*   **Component:** Product Grid
*   **Endpoint:** `GET /products/search` (with various filter parameters)
*   **Component:** Filter Sidebar
*   **Endpoint:** Uses the `facets` object from the `GET /products/search` response.

### **Page: Product Detail**
*   **Component:** Product Details Display
*   **Endpoint:** `GET /products/:id`
*   **Component:** "Add to Cart" Button
*   **Endpoint:** `POST /cart/items`
*   **Component:** "Add to Wishlist" Button
*   **Endpoint:** `POST /wishlist/items`

### **Page: Cart**
*   **Component:** Cart Display
*   **Endpoint:** `GET /cart`
*   **Component:** Quantity Selector
*   **Endpoint:** `PUT /cart/items/:id`
*   **Component:** "Remove Item" Button
*   **Endpoint:** `DELETE /cart/items/:id`

### **Page: Wishlist**
*   **Component:** Wishlist Display
*   **Endpoint:** `GET /wishlist`
*   **Component:** "Remove from Wishlist" Button
*   **Endpoint:** `DELETE /wishlist/items/:product_variant_id`

### **Page: Checkout**
*   **Component:** Address Selector
*   **Endpoint:** `GET /my-addresses`, `POST /addresses`
*   **Component:** "Place Order" Button
*   **Endpoint:** `POST /orders`

### **Page: My Orders**
*   **Component:** Order History List
*   **Endpoint:** `GET /my-orders`
*   **Component:** "View Details" Link
*   **Endpoint:** `GET /my-orders/:id`
*   **Component:** "Request Return" Button
*   **Endpoint:** `POST /returns`

### **Page: Authentication (Login/Signup)**
*   **Component:** Signup Form
*   **Endpoint:** `POST /signup`
*   **Component:** Login Form
*   **Endpoint:** `POST /login`

---

## 2. Supplier Frontend Application

### **Page: Dashboard**
*   **Component:** Sales Summary
*   **Endpoint:** `GET /supplier/orders` (with aggregation/summary parameters)

### **Page: My Profile**
*   **Component:** Profile Form
*   **Endpoint:** `GET /supplier/profile`, `PUT /supplier/profile`

### **Page: Products**
*   **Component:** Product List
*   **Endpoint:** `GET /supplier/products`
*   **Component:** "Create Product" Form
*   **Endpoint:** `POST /supplier/products`
*   **Component:** "Edit Product" Form
*   **Endpoint:** `GET /supplier/products/:id`, `PUT /supplier/products/:id`

### **Page: Orders**
*   **Component:** Order Item List
*   **Endpoint:** `GET /supplier/orders`
*   **Component:** "Mark as Shipped" Button
*   **Endpoint:** `PUT /supplier/orders/:item_id/ship`

### **Page: Returns**
*   **Component:** Return Request List
*   **Endpoint:** `GET /supplier/returns`
*   **Component:** "Approve/Reject Return" Buttons
*   **Endpoint:** `PUT /supplier/returns/:id/approve` (or `/reject`)