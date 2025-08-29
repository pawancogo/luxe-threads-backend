# Sprint 8 Execution Plan: Reviews & Returns

**Goal:** Complete the core application loop by implementing post-purchase functionality: product reviews and a full return-request lifecycle.

---

## Part 1: Backend (Rails API)

### Step 1: Generate Review and Return Models & Controllers
Generate the necessary models and controllers for these features.

**Commands to run:**
```bash
bundle exec rails g model Review user:references product:references rating:integer comment:text verified_purchase:boolean
bundle exec rails g model ReturnRequest user:references order:references status:string resolution_type:string
bundle exec rails g model ReturnItem return_request:references order_item:references quantity:integer reason:text
bundle exec rails g model ReturnMedia return_item:references media_url:string media_type:string
bundle exec rails db:migrate

bundle exec rails g controller api/v1/Reviews create
bundle exec rails g controller api/v1/ReturnRequests create index show
```

### Step 2: Define Review and Return Routes
Add the API endpoints for these new features.

**File: [`config/routes.rb`](config/routes.rb)** (Add this within the `api/v1` namespace)
```ruby
namespace :api do
  namespace :v1 do
    # ...
    # Allow reviews to be nested under products
    resources :products, only: [] do
      resources :reviews, only: [:create, :index]
    end
    
    resources :return_requests, only: [:create, :index, :show]
  end
end
```

### Step 3: Implement Review Logic
The `ReviewsController` will handle the creation of new reviews. We'll add a check to ensure the user has actually purchased the product.

**File: [`app/controllers/api/v1/reviews_controller.rb`](app/controllers/api/v1/reviews_controller.rb)**
```ruby
class Api::V1::ReviewsController < ApplicationController
  before_action :set_product

  def create
    # Check if the user has purchased this product
    has_purchased = current_user.orders.joins(:order_items__product_variant)
                                      .where(product_variants: { product_id: @product.id }, status: :delivered)
                                      .exists?

    return render json: { error: 'You can only review products you have purchased.' }, status: :forbidden unless has_purchased

    @review = @product.reviews.build(review_params)
    @review.user = current_user
    @review.verified_purchase = true

    if @review.save
      render json: @review, status: :created
    else
      render json: @review.errors, status: :unprocessable_entity
    end
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end
```

### Step 4: Implement Return Request Logic
This controller will manage the creation and viewing of return requests.

**File: [`app/controllers/api/v1/return_requests_controller.rb`](app/controllers/api/v1/return_requests_controller.rb)**
```ruby
class Api::V1::ReturnRequestsController < ApplicationController
  def index
    @return_requests = current_user.return_requests
    render json: @return_requests
  end

  def show
    @return_request = current_user.return_requests.find(params[:id])
    render json: @return_request.as_json(include: :return_items)
  end

  def create
    @return_request = current_user.return_requests.build(return_request_params)
    # The frontend would send the items to be returned in the params.
    # Here you would add logic to create the associated ReturnItem records.
    # For simplicity, we are only showing the creation of the main request.

    if @return_request.save
      render json: @return_request, status: :created
    else
      render json: @return_request.errors, status: :unprocessable_entity
    end
  end

  private

  def return_request_params
    params.require(:return_request).permit(:order_id, :resolution_type, return_items_attributes: [:order_item_id, :quantity, :reason])
  end
end
```
*(Note: You would need to add `accepts_nested_attributes_for :return_items` to the `ReturnRequest` model for this to work.)*

---

## Part 2: User Frontend

### Step 1: Add "Write a Review" Functionality
On the "My Orders" page, for delivered items, add a button that opens a modal or navigates to a form for submitting a review. The form will post to `POST /api/v1/products/:product_id/reviews`.

### Step 2: Display Reviews on Product Detail Page (PDP)
On the PDP, fetch and display existing reviews for the product.

### Step 3: Create the "Request Return" Form
On the "Order Details" page, allow the user to select items from the order and initiate a return request. The form should allow them to specify quantity, reason, and resolution type (refund/replacement). This form will post to `POST /api/v1/return_requests`.

### Step 4: Create a "My Returns" Page
Create a page where users can view the status of their past and current return requests by fetching data from `GET /api/v1/return_requests`.

---

## Part 3: Supplier & Admin

### Step 1: Manage Returns in Admin Dashboard
Enhance the `rails_admin` UI to allow order admins to view, approve, and process return requests. This would involve adding custom actions similar to the product verification in Sprint 5.

### Step 2: Display Return Information to Suppliers
In the Supplier Frontend, create a "Returns" page that shows suppliers which of their items have been requested for return, allowing them to see the reason and status.

This completes the final sprint of the core feature set. The application now supports the full, end-to-end e-commerce lifecycle.