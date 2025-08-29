# Sprint 6 Execution Plan: Checkout & Order Placement

**Goal:** Implement the multi-step checkout flow, allowing users to manage their addresses and convert their cart into a confirmed order.

---

## Part 1: Backend (Rails API)

### Step 1: Generate Order and Address Models & Controllers
We already generated the `Order`, `OrderItem`, and `Address` models in Sprint 1. Now, we'll generate the controllers to manage them.

**Commands to run:**
```bash
bundle exec rails g controller api/v1/Addresses index create update destroy
bundle exec rails g controller api/v1/Orders create show
```

### Step 2: Define Checkout and Address Routes
Add the necessary routes for managing addresses and creating an order.

**File: [`config/routes.rb`](config/routes.rb)** (Add this within the `api/v1` namespace)
```ruby
namespace :api do
  namespace :v1 do
    # ...
    resources :addresses, only: [:index, :create, :update, :destroy]
    resources :orders, only: [:create, :show, :index]
  end
end
```

### Step 3: Implement Address Management Logic
The `AddressesController` will handle CRUD operations for the current user's address book.

**File: [`app/controllers/api/v1/addresses_controller.rb`](app/controllers/api/v1/addresses_controller.rb)**
```ruby
class Api::V1::AddressesController < ApplicationController
  before_action :set_address, only: [:update, :destroy]

  def index
    @addresses = current_user.addresses
    render json: @addresses
  end

  def create
    @address = current_user.addresses.build(address_params)
    if @address.save
      render json: @address, status: :created
    else
      render json: @address.errors, status: :unprocessable_entity
    end
  end

  def update
    if @address.update(address_params)
      render json: @address
    else
      render json: @address.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @address.destroy
  end

  private

  def set_address
    @address = current_user.addresses.find(params[:id])
  end

  def address_params
    params.require(:address).permit(:address_type, :full_name, :phone_number, :line1, :line2, :city, :state, :postal_code, :country)
  end
end
```

### Step 4: Implement Order Creation Logic
This is the most critical part of this sprint. The `OrdersController` will handle the conversion of a cart into an order. This involves creating the `Order` and `OrderItem` records, calculating the total, and clearing the user's cart.

**File: [`app/controllers/api/v1/orders_controller.rb`](app/controllers/api/v1/orders_controller.rb)**
```ruby
class Api::V1::OrdersController < ApplicationController
  before_action :set_order, only: [:show]

  def index
    @orders = current_user.orders
    render json: @orders.includes(:order_items)
  end

  def show
    render json: @order.as_json(include: { order_items: { include: :product_variant } })
  end

  # POST /api/v1/orders
  def create
    cart = current_user.cart
    return render json: { error: 'Cart is empty' }, status: :unprocessable_entity if cart.cart_items.empty?

    # Use a transaction to ensure all or nothing is saved
    ActiveRecord::Base.transaction do
      @order = current_user.orders.build(order_params)
      @order.total_amount = 0 # We will calculate this

      cart.cart_items.each do |cart_item|
        variant = cart_item.product_variant
        order_item = @order.order_items.build(
          product_variant_id: variant.id,
          quantity: cart_item.quantity,
          price_at_purchase: variant.discounted_price || variant.price
        )
        @order.total_amount += order_item.price_at_purchase * order_item.quantity
        # Decrement stock (a more robust solution would lock the variant row)
        variant.update!(stock_quantity: variant.stock_quantity - cart_item.quantity)
      end
      
      @order.save!
      # Clear the cart after successful order creation
      cart.cart_items.destroy_all
    end

    render json: @order, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  private

  def set_order
    @order = current_user.orders.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:shipping_address_id, :billing_address_id, :shipping_method)
  end
end
```
*(Note: We are not handling payments yet; that is in Sprint 7. The order status will default to 'pending' or similar.)*

---

## Part 2: User Frontend

### Step 1: Create the Checkout Page
This will be a multi-step page or a series of pages.

**Example File Structure:**
- `pages/checkout/address.js`
- `pages/checkout/review.js`
- `pages/checkout/confirmation/[id].js`

### Step 2: Build the Address Management Step
On the `address.js` page, fetch the user's addresses from `GET /api/v1/addresses`. Allow the user to select an existing shipping/billing address or create a new one using a form that posts to `POST /api/v1/addresses`.

### Step 3: Build the Order Review Step
On the `review.js` page, show the items from the cart again, the selected addresses, and the calculated total. This page will have the "Place Order" button.

### Step 4: Implement the "Place Order" Logic
When the user clicks "Place Order," send the request to the backend.

**Example Code Snippet (in `review.js`):**
```javascript
const handlePlaceOrder = async () => {
  const token = getAuthToken();
  const response = await fetch('http://localhost:3000/api/v1/orders', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`,
    },
    body: JSON.stringify({
      order: {
        shipping_address_id: selectedShippingAddress.id,
        billing_address_id: selectedBillingAddress.id,
        shipping_method: 'Standard'
      }
    }),
  });

  if (response.ok) {
    const orderData = await response.json();
    // Redirect to the confirmation page
    router.push(`/checkout/confirmation/${orderData.id}`);
  } else {
    alert('Failed to place order.');
  }
};
```

### Step 5: Build the Order Confirmation Page
The `confirmation/[id].js` page will fetch the completed order details from `GET /api/v1/orders/:id` and display a "Thank You" message to the user with their order summary.

This completes Sprint 6. The core shopping flow, from adding to cart to placing an order, is now functional.