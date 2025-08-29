# Sprint 7 Execution Plan: Payments & Order Management

**Goal:** Integrate a payment gateway to finalize orders and build the interfaces for customers and suppliers to track and manage them.

---

## Part 1: Backend (Rails API)

### Step 1: Integrate a Payment Gateway (Stripe)
We'll use Stripe, a popular and developer-friendly payment processor.

**Add the Stripe Gem:**
Add `gem 'stripe'` to your `Gemfile` and run `bundle install` (once your network issues are resolved).

**Configure Stripe Initializer:**
Create a file to configure your Stripe API keys. These should be stored securely, for example, in Rails credentials.

**File: [`config/initializers/stripe.rb`](config/initializers/stripe.rb)**
```ruby
Stripe.api_key = Rails.application.credentials.stripe[:secret_key]
```

### Step 2: Modify the Order Creation Flow
Update the `OrdersController` to create a Stripe Payment Intent when an order is initiated. The client-side will use the `client_secret` from this intent to confirm the payment.

**File: [`app/controllers/api/v1/orders_controller.rb`](app/controllers/api/v1/orders_controller.rb)** (Modify the `create` action)
```ruby
class Api::V1::OrdersController < ApplicationController
  # ...

  def create
    cart = current_user.cart
    return render json: { error: 'Cart is empty' }, status: :unprocessable_entity if cart.cart_items.empty?

    # We will now create the order in a 'pending' state first
    @order = current_user.orders.build(order_params.except(:payment_method_id))
    @order.status = 'pending' # Initial status
    @order.total_amount = calculate_total(cart)
    
    # We create the Payment Intent with Stripe here
    begin
      payment_intent = Stripe::PaymentIntent.create(
        amount: (@order.total_amount * 100).to_i, # Amount in cents
        currency: 'usd',
        payment_method: params[:order][:payment_method_id],
        confirm: true,
        metadata: { order_id: @order.id } # Link intent to our order
      )

      # If payment is successful, we proceed with saving the order
      ActiveRecord::Base.transaction do
        transfer_cart_items_to_order(cart, @order)
        @order.payment_status = 'complete'
        @order.status = 'paid' # Or 'processing'
        @order.save!
        cart.cart_items.destroy_all
      end

      render json: { order: @order, client_secret: payment_intent.client_secret }, status: :created
    
    rescue Stripe::CardError => e
      render json: { errors: e.message }, status: :payment_required
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def calculate_total(cart)
    cart.cart_items.sum { |item| (item.product_variant.discounted_price || item.product_variant.price) * item.quantity }
  end
  
  def transfer_cart_items_to_order(cart, order)
    cart.cart_items.each do |cart_item|
      # ... logic from previous sprint to build order items and decrement stock
    end
  end

  def order_params
    params.require(:order).permit(:shipping_address_id, :billing_address_id, :shipping_method, :payment_method_id)
  end
end
```

### Step 3: Create Supplier Order Management Endpoint
Suppliers need to see which of their products have been ordered. We'll create an endpoint that returns `OrderItems` belonging to a supplier.

**Command to run:**
```bash
bundle exec rails g controller api/v1/SupplierOrders index
```
**File: [`config/routes.rb`](config/routes.rb)** (Add this within the `api/v1` namespace)
```ruby
namespace :api do
  namespace :v1 do
    # ...
    get 'supplier/orders', to: 'supplier_orders#index'
  end
end
```

**File: [`app/controllers/api/v1/supplier_orders_controller.rb`](app/controllers/api/v1/supplier_orders_controller.rb)**
```ruby
class Api::V1::SupplierOrdersController < ApplicationController
  before_action :authorize_supplier!

  def index
    # Find all order items for products belonging to the current supplier
    @order_items = OrderItem.joins(product_variant: { product: :supplier_profile })
                             .where(supplier_profiles: { id: current_user.supplier_profile.id })
                             .order(created_at: :desc)
    
    render json: @order_items.as_json(include: { order: { include: :user }, product_variant: { include: :product } })
  end

  private

  def authorize_supplier!
    render json: { error: 'Not Authorized' }, status: :unauthorized unless current_user.supplier?
  end
end
```

---

## Part 2: User Frontend

### Step 1: Integrate Stripe.js
In your checkout page, you'll need to use the Stripe.js library to securely collect card details.

**Include the Stripe.js script in your main HTML layout:**
```html
<script src="https://js.stripe.com/v3/"></script>
```

**Wrap your checkout form with the Stripe `Elements` provider:**
```javascript
import { loadStripe } from '@stripe/stripe-js';
import { Elements } from '@stripe/react-stripe-js';

const stripePromise = loadStripe('YOUR_STRIPE_PUBLISHABLE_KEY');

const CheckoutPage = () => {
  return (
    <Elements stripe={stripePromise}>
      <CheckoutForm />
    </Elements>
  );
};
```

### Step 2: Update the Checkout Form
The `CheckoutForm` component will use Stripe's `CardElement` to create a secure input for card details.

**Example Code Snippet (`CheckoutForm.js`):**
```javascript
import { useStripe, useElements, CardElement } from '@stripe/react-stripe-js';

const CheckoutForm = () => {
  const stripe = useStripe();
  const elements = useElements();

  const handlePlaceOrder = async (e) => {
    e.preventDefault();
    if (!stripe || !elements) return;

    const cardElement = elements.getElement(CardElement);
    const { error, paymentMethod } = await stripe.createPaymentMethod({
      type: 'card',
      card: cardElement,
    });

    if (error) {
      console.error(error);
      return;
    }

    // Now call your backend with the paymentMethod.id
    const response = await fetch('/api/v1/orders', {
      method: 'POST',
      // ... headers and other order data
      body: JSON.stringify({
        // ... address, etc.
        order: { payment_method_id: paymentMethod.id, ...otherOrderData }
      })
    });
    // ... handle response and redirect
  };

  return (
    <form onSubmit={handlePlaceOrder}>
      <CardElement />
      <button type="submit" disabled={!stripe}>Place Order</button>
    </form>
  );
};
```

### Step 3: Create "My Orders" Page for Customers
Create a new page where users can view their order history by fetching from `GET /api/v1/orders`.

**Example File Structure:**
- `pages/my-orders.js`

---

## Part 3: Supplier Frontend

### Step 1: Create an "Orders" Page
Create a new page in the supplier application to display all incoming orders for their products.

**Example File Structure:**
- `pages/orders.js`

### Step 2: Implement the Supplier Order View
Fetch data from `GET /api/v1/supplier/orders` and display it in a table or list, showing the product, quantity, customer details, and order date. This gives suppliers a view of what they need to fulfill.

This completes Sprint 7. The application can now process real payments, and both customers and suppliers have visibility into orders.