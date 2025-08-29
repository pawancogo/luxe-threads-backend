# Sprint 1 Execution Plan: User Authentication & Roles

**Goal:** Implement the foundational database structure, secure user signup, and login for both customers and suppliers.

---

## Part 1: Backend (Rails API)

### Step 1: Create and Prepare the Database
After `bundle install` is successful, create the PostgreSQL database.

**Command to run:**
```bash
bundle exec rails db:create
```

### Step 2: Generate All Application Models
These commands will generate the model files and the initial migration files for our entire schema.

**Commands to run:**
```bash
bundle exec rails g model User first_name:string last_name:string email:string:uniq phone_number:string:uniq password_digest:string role:integer
bundle exec rails g model SupplierProfile user:references company_name:string gst_number:string description:text website_url:string verified:boolean
bundle exec rails g model Category name:string parent:references
bundle exec rails g model Brand name:string logo_url:string
bundle exec rails g model Product supplier_profile:references category:references brand:references name:string description:text status:integer verified_by_admin:references verified_at:datetime
bundle exec rails g model ProductVariant product:references sku:string:uniq price:decimal discounted_price:decimal stock_quantity:integer weight_kg:float
bundle exec rails g model ProductImage product_variant:references image_url:string alt_text:string display_order:integer
bundle exec rails g model Address user:references address_type:string full_name:string phone_number:string line1:string line2:string city:string state:string postal_code:string country:string
bundle exec rails g model Order user:references shipping_address:references billing_address:references status:string payment_status:string shipping_method:string total_amount:decimal
bundle exec rails g model OrderItem order:references product_variant:references quantity:integer price_at_purchase:decimal
```
*(Note: Additional models like `Review`, `Wishlist`, etc., will be generated in later sprints as needed.)*

### Step 3: Configure the User Model
Open `app/models/user.rb` and add the security, validation, and role management logic.

**File: [`app/models/user.rb`](app/models/user.rb)**
```ruby
class User < ApplicationRecord
  has_secure_password

  # Define roles using an enum
  enum role: {
    customer: 0,
    supplier: 1,
    super_admin: 2,
    product_admin: 3,
    order_admin: 4
  }

  # Associations
  has_one :supplier_profile, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :reviews, dependent: :destroy

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone_number, presence: true, uniqueness: true
  validates :role, presence: true
end
```

### Step 4: Configure All Other Models
Open the generated model files (e.g., `app/models/product.rb`) and add the `belongs_to` and `has_many` associations as defined in our schema. For example:

**File: [`app/models/product.rb`](app/models/product.rb)**
```ruby
class Product < ApplicationRecord
  belongs_to :supplier_profile
  belongs_to :category
  belongs_to :brand
  belongs_to :verified_by_admin, class_name: 'User', optional: true

  has_many :product_variants, dependent: :destroy
  has_many :reviews, dependent: :destroy

  enum status: { pending: 0, active: 1, rejected: 2, archived: 3 }
end
```
*(Apply similar logic for all other models.)*

### Step 5: Run the Database Migrations
This command will create all the tables and columns in your database.

**Command to run:**
```bash
bundle exec rails db:migrate
```

### Step 6: Create Authentication Routes
Define the API endpoints for signup and login in your routes file.

**File: [`config/routes.rb`](config/routes.rb)**
```ruby
Rails.application.routes.draw do
  # ... other routes
  namespace :api do
    namespace :v1 do
      post 'signup', to: 'users#create'
      post 'login', to: 'authentication#create'
      # Add other resources here as we build them
    end
  end
end
```

### Step 7: Create Authentication Controllers
Generate the controllers that will handle the logic for our new routes.

**Commands to run:**
```bash
bundle exec rails g controller api/v1/Users create
bundle exec rails g controller api/v1/Authentication create
```

### Step 8: Implement Signup and Login Logic
Add the code to your new controllers. You will need a `JsonWebToken` concern to handle JWTs.

**Create File: [`app/controllers/concerns/json_web_token.rb`](app/controllers/concerns/json_web_token.rb)**
```ruby
require "jwt"
module JsonWebToken
  extend ActiveSupport::Concern
  SECRET_KEY = Rails.application.secret_key_base

  def jwt_encode(payload, exp: 7.days.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def jwt_decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new decoded
  end
end
```

**File: [`app/controllers/api/v1/users_controller.rb`](app/controllers/api/v1/users_controller.rb)**
```ruby
class Api::V1::UsersController < ApplicationController
  include JsonWebToken

  # POST /api/v1/signup
  def create
    @user = User.new(user_params)
    if @user.save
      token = jwt_encode(user_id: @user.id)
      render json: { token: token, user: { id: @user.id, email: @user.email, role: @user.role } }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone_number, :password, :password_confirmation, :role)
  end
end
```

**File: [`app/controllers/api/v1/authentication_controller.rb`](app/controllers/api/v1/authentication_controller.rb)**
```ruby
class Api::V1::AuthenticationController < ApplicationController
  include JsonWebToken

  # POST /api/v1/login
  def create
    @user = User.find_by_email(params[:email])
    if @user&.authenticate(params[:password])
      token = jwt_encode(user_id: @user.id)
      render json: { token: token }, status: :ok
    else
      render json: { error: 'unauthorized' }, status: :unauthorized
    end
  end
end
```

---

## Part 2: Frontend (User & Supplier Apps)

### Step 1: Create Signup/Login Pages
In both your Next.js frontend applications (`user-frontend` and `supplier-frontend`), create the pages for authentication.

**Example File Structure:**
- `pages/signup.js`
- `pages/login.js`

### Step 2: Build the Signup Form
Here is example code for a React signup component.

**Example Code: `components/SignupForm.js`**
```javascript
import React, { useState } from 'react';

const SignupForm = () => {
  const [formData, setFormData] = useState({
    first_name: '',
    last_name: '',
    email: '',
    phone_number: '',
    password: '',
    role: 'customer' // or 'supplier' depending on the frontend
  });

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const response = await fetch('http://localhost:3000/api/v1/signup', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ user: formData })
      });
      const data = await response.json();
      if (response.ok) {
        // Save the token and redirect
        localStorage.setItem('token', data.token);
        // window.location.href = '/'; // or to a dashboard
      } else {
        // Handle errors
        console.error(data.errors);
      }
    } catch (error) {
      console.error('Signup failed:', error);
    }
  };

  // ... JSX for the form inputs and submit button
  return <form onSubmit={handleSubmit}>...</form>;
};

export default SignupForm;
```

Once you have completed these steps, Sprint 1 will be complete. You will have a working authentication system for your backend and functional signup/login pages on the frontends. We can then proceed to Sprint 2.