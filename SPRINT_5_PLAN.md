# Sprint 5 Execution Plan: Admin Verification & Cart

**Goal:** Empower admins to approve or reject new products and enable customers to manage a shopping cart.

---

## Part 1: Backend (Rails API)

### Step 1: Enhance Rails Admin for Product Verification
We need to add custom actions to the `rails_admin` interface to allow admins to approve or reject products.

**File: [`config/initializers/rails_admin.rb`](config/initializers/rails_admin.rb)** (Add these action configurations)
```ruby
RailsAdmin.config do |config|
  # ... existing configurations ...

  config.actions do
    # ... existing actions ...
    
    # Add custom actions for product verification
    member :approve_product do
      visible? { bindings[:object].is_a?(Product) && bindings[:object].pending? }
      link_icon 'icon-check'
      pjax false
      action :post do
        bindings[:object].update(status: :active, verified_by_admin_id: bindings[:view]._current_user.id, verified_at: Time.current)
        redirect_to back_or_index, notice: 'Product approved successfully.'
      end
    end

    member :reject_product do
      visible? { bindings[:object].is_a?(Product) && bindings[:object].pending? }
      link_icon 'icon-remove'
      pjax false
      action :post do
        bindings[:object].update(status: :rejected, verified_by_admin_id: bindings[:view]._current_user.id, verified_at: Time.current)
        redirect_to back_or_index, notice: 'Product rejected successfully.'
      end
    end
  end

  # Configure the Product model in RailsAdmin
  config.model 'Product' do
    list do
      field :id
      field :name
      field :supplier_profile
      field :status, :enum
      field :created_at
    end
    # Include our custom actions
    show { include_all_fields; field :approve_product; field :reject_product }
    edit { include_all_fields }
  end
end
```

### Step 2: Create Cart Models
We will model the cart using the session for guest users and associate it with a user account upon login. For simplicity in this sprint's API, we will create a `Cart` and `CartItem` model linked directly to the user.

**Commands to run:**
```bash
bundle exec rails g model Cart user:references
bundle exec rails g model CartItem cart:references product_variant:references quantity:integer
bundle exec rails db:migrate
```

### Step 3: Implement Cart Logic in Models
The `User` model should automatically get a cart.

**File: [`app/models/user.rb`](app/models/user.rb)**
```ruby
class User < ApplicationRecord
  # ...
  has_one :cart, dependent: :destroy
  after_create :create_cart

  private

  def create_cart
    Cart.create(user: self)
  end
end
```
**File: [`app/models/cart.rb`](app/models/cart.rb)**
```ruby
class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :destroy
end
```
**File: [`app/models/cart_item.rb`](app/models/cart_item.rb)**
```ruby
class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product_variant
end
```

### Step 4: Create Cart API Controller & Routes
Generate a controller to manage cart items.

**Command to run:**
```bash
bundle exec rails g controller api/v1/CartItems index create update destroy --skip-routes
```

**File: [`config/routes.rb`](config/routes.rb)** (Add this within the `api/v1` namespace)
```ruby
namespace :api do
  namespace :v1 do
    # ...
    # Use a singular resource for the cart, as a user only has one.
    resource :cart, only: [:show], controller: :carts
    resources :cart_items, only: [:create, :update, :destroy]
  end
end
```

### Step 5: Implement Cart API Logic
Add the logic to fetch, add, update, and remove items from the current user's cart.

**File: [`app/controllers/api/v1/carts_controller.rb`](app/controllers/api/v1/carts_controller.rb)** (Create this file)
```ruby
class Api::V1::CartsController < ApplicationController
  def show
    @cart = current_user.cart
    render json: @cart.cart_items.includes(product_variant: { product: :brand })
  end
end
```

**File: [`app/controllers/api/v1/cart_items_controller.rb`](app/controllers/api/v1/cart_items_controller.rb)**
```ruby
class Api::V1::CartItemsController < ApplicationController
  before_action :set_cart

  def create
    # Find item if it already exists to update quantity
    @cart_item = @cart.cart_items.find_or_initialize_by(product_variant_id: params[:product_variant_id])
    @cart_item.quantity = (@cart_item.quantity || 0) + params[:quantity].to_i
    
    if @cart_item.save
      render json: @cart.cart_items, status: :created
    else
      render json: @cart_item.errors, status: :unprocessable_entity
    end
  end

  def update
    @cart_item = @cart.cart_items.find(params[:id])
    if @cart_item.update(quantity: params[:quantity].to_i)
      render json: @cart.cart_items
    else
      render json: @cart_item.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @cart_item = @cart.cart_items.find(params[:id])
    @cart_item.destroy
    render json: @cart.cart_items
  end

  private

  def set_cart
    @cart = current_user.cart
  end
end
```

---

## Part 2: User Frontend

### Step 1: Create Cart Component
Build a reusable component that displays the contents of the cart. This could be a full page (`pages/cart.js`) or a slide-out drawer/modal.

### Step 2: Implement "Add to Cart" Functionality
On the Product Detail Page (PDP), add a button that calls the `POST /api/v1/cart_items` endpoint.

**Example Code Snippet (in PDP component):**
```javascript
const [quantity, setQuantity] = useState(1);

const handleAddToCart = async () => {
  const token = getAuthToken();
  const response = await fetch('http://localhost:3000/api/v1/cart_items', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`,
    },
    body: JSON.stringify({
      product_variant_id: selectedVariant.id,
      quantity: quantity,
    }),
  });

  if (response.ok) {
    alert('Item added to cart!');
    // Optionally, trigger a re-fetch of cart data to update a cart icon/counter in the header
  } else {
    alert('Failed to add item.');
  }
};
```

### Step 3: Implement Cart View
On the cart page/component, fetch data from `GET /api/v1/cart`. Display the items and allow users to update quantities (`PUT /api/v1/cart_items/:id`) or remove items (`DELETE /api/v1/cart_items/:id`).

This completes Sprint 5. Admins can now manage the product lifecycle, and customers can begin the shopping process.