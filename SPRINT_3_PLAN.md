# Sprint 3 Execution Plan: Product & Variant Management

**Goal:** Enable suppliers to create, view, update, and delete their products and product variants, including handling image uploads.

---

## Part 1: Backend (Rails API)

### Step 1: Generate Product Management Controllers
We need controllers to handle the logic for `Products` and their nested `ProductVariants`.

**Commands to run:**
```bash
bundle exec rails g controller api/v1/Products index show create update destroy
bundle exec rails g controller api/v1/ProductVariants create update destroy --skip-routes
```

### Step 2: Define Product Management Routes
Update the routes file to include CRUD endpoints for products and nested routes for their variants.

**File: [`config/routes.rb`](config/routes.rb)** (Add this within the `api/v1` namespace)
```ruby
namespace :api do
  namespace :v1 do
    # ... other routes
    resources :products, only: [:index, :show, :create, :update, :destroy] do
      resources :product_variants, only: [:create, :update, :destroy]
    end
    
    # Also, add routes for fetching Categories and Brands for the forms
    resources :categories, only: [:index]
    resources :brands, only: [:index]
  end
end
```

### Step 3: Implement Product Controller Logic
This controller will manage the core product information. It will be scoped to the current supplier.

**File: [`app/controllers/api/v1/products_controller.rb`](app/controllers/api/v1/products_controller.rb)**
```ruby
class Api::V1::ProductsController < ApplicationController
  before_action :authorize_supplier!
  before_action :set_product, only: [:show, :update, :destroy]

  # GET /api/v1/products
  def index
    @products = current_user.supplier_profile.products
    render json: @products
  end

  # GET /api/v1/products/:id
  def show
    render json: @product
  end

  # POST /api/v1/products
  def create
    @product = current_user.supplier_profile.products.build(product_params)
    if @product.save
      render json: @product, status: :created
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/products/:id
  def update
    if @product.update(product_params)
      render json: @product
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/products/:id
  def destroy
    @product.destroy
  end

  private

  def authorize_supplier!
    render json: { error: 'Not Authorized' }, status: :unauthorized unless current_user.supplier?
  end

  def set_product
    @product = current_user.supplier_profile.products.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :category_id, :brand_id)
  end
end
```

### Step 4: Implement Product Variant Controller Logic
This controller manages the variants that belong to a specific product.

**File: [`app/controllers/api/v1/product_variants_controller.rb`](app/controllers/api/v1/product_variants_controller.rb)**
```ruby
class Api::V1::ProductVariantsController < ApplicationController
  before_action :authorize_supplier!
  before_action :set_product

  # POST /api/v1/products/:product_id/product_variants
  def create
    @variant = @product.product_variants.build(variant_params)
    if @variant.save
      render json: @variant, status: :created
    else
      render json: @variant.errors, status: :unprocessable_entity
    end
  end
  
  # ... implement update and destroy actions similarly ...

  private

  def authorize_supplier!
    render json: { error: 'Not Authorized' }, status: :unauthorized unless current_user.supplier?
  end

  def set_product
    @product = current_user.supplier_profile.products.find(params[:product_id])
  end

  def variant_params
    params.require(:product_variant).permit(:sku, :price, :stock_quantity, :weight_kg)
  end
end
```

### Step 5: Implement Category and Brand Controllers
These will be simple controllers to provide data for frontend forms.

**File: [`app/controllers/api/v1/categories_controller.rb`](app/controllers/api/v1/categories_controller.rb)**
```ruby
class Api::V1::CategoriesController < ApplicationController
  skip_before_action :authenticate_request, only: [:index]

  def index
    @categories = Category.all
    render json: @categories
  end
end
```
*(Implement `brands_controller.rb` in the same way)*

### Step 6: Configure Active Storage for Image Uploads
Rails comes with built-in support for file uploads. First, install the migrations.

**Command to run:**
```bash
bundle exec rails active_storage:install
bundle exec rails db:migrate
```

Next, associate images with your `ProductImage` model. Since we'll have many images per variant, we will attach them directly to the `ProductVariant` for simplicity in this sprint.

**Modify Model: [`app/models/product_variant.rb`](app/models/product_variant.rb)**
```ruby
class ProductVariant < ApplicationRecord
  # ... existing code ...
  has_many_attached :images
end
```
*Note: This is a simplified approach. The `ProductImage` model from the schema would be used for adding more details like `alt_text` and `display_order`.*

Then, update your `ProductVariant` controller to accept image uploads. The frontend will need to send these as `multipart/form-data`.

**File: [`app/controllers/api/v1/product_variants_controller.rb`](app/controllers/api/v1/product_variants_controller.rb)** (Update `variant_params`)
```ruby
def variant_params
  # Add :images to the permitted parameters
  params.require(:product_variant).permit(:sku, :price, :stock_quantity, :weight_kg, images: [])
end
```

---

## Part 2: Supplier Frontend

### Step 1: Create a "My Products" Page
This page will list all products for the logged-in supplier and have a button to create a new one.

**Example File Structure:**
- `pages/products/index.js`
- `pages/products/new.js`
- `pages/products/[id]/edit.js`

### Step 2: Build the Product List Component
Fetch and display a list of the supplier's products.

**Example Code: `pages/products/index.js`**
```javascript
import React, { useState, useEffect } from 'react';
import Link from 'next/link';

const getAuthToken = () => localStorage.getItem('token');

const ProductListPage = () => {
  const [products, setProducts] = useState([]);

  useEffect(() => {
    const fetchProducts = async () => {
      const token = getAuthToken();
      const response = await fetch('http://localhost:3000/api/v1/products', {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (response.ok) {
        setProducts(await response.json());
      }
    };
    fetchProducts();
  }, []);

  return (
    <div>
      <h1>My Products</h1>
      <Link href="/products/new">Create New Product</Link>
      <ul>
        {products.map(product => (
          <li key={product.id}>{product.name} - {product.status}</li>
        ))}
      </ul>
    </div>
  );
};

export default ProductListPage;
```

### Step 3: Build the Product Creation/Edit Form
This will be a complex, multi-step form.
*   **Step 1:** Enter basic product details (name, description, category, brand). The category and brand dropdowns will be populated by fetching from `/api/v1/categories` and `/api/v1/brands`.
*   **Step 2:** After creating the product, redirect to an "edit" page where the supplier can add/edit `ProductVariants`.
*   **Step 3:** For each variant, allow SKU, price, and stock to be entered.
*   **Step 4:** For each variant, include a file input to upload images. The form's encoding type must be set to `multipart/form-data`.

**Example Image Upload Logic:**
```javascript
const handleImageChange = (e) => {
  // Set the image files in state
  setVariantImages(e.target.files);
};

const handleVariantSubmit = async (e) => {
  e.preventDefault();
  const token = getAuthToken();
  
  const formData = new FormData();
  formData.append('product_variant[sku]', variant.sku);
  formData.append('product_variant[price]', variant.price);
  // Append other variant fields...

  // Append images
  for (const image of variantImages) {
    formData.append('product_variant[images][]', image);
  }

  const response = await fetch(`/api/v1/products/${productId}/product_variants`, {
    method: 'POST',
    headers: { 'Authorization': `Bearer ${token}` }, // Note: No 'Content-Type' header for FormData
    body: formData,
  });
  // ... handle response
};
```
This completes Sprint 3, providing the core product management functionality for suppliers.