# Sprint 2 Execution Plan: Admin Foundation & Supplier Profiles

**Goal:** Establish a secure admin dashboard for data management and enable suppliers to manage their business profiles.

---

## Part 1: Backend (Rails API)

### Step 1: Install and Configure Rails Admin
This tool will give us a powerful, out-of-the-box UI for administration.

**Command to run:**
```bash
bundle exec rails g rails_admin:install
```
This command will add `mount RailsAdmin::Engine => '/admin', as: 'rails_admin'` to your `config/routes.rb` and create an initializer file.

### Step 2: Secure the Admin Dashboard with Pundit
We need to ensure only users with admin roles can access the dashboard. First, generate the base Pundit policy.

**Command to run:**
```bash
bundle exec rails g pundit:install
```
This creates `app/policies/application_policy.rb`. Now, we'll configure `rails_admin` to use Pundit.

**File: [`config/initializers/rails_admin.rb`](config/initializers/rails_admin.rb)**
```ruby
RailsAdmin.config do |config|
  # ==> Pundit integration <==
  config.authorize_with :pundit

  # ... other configurations

  config.current_user_method do
    # This assumes you have a helper method to find the current user from the token.
    # We will build this helper in the ApplicationController.
    current_user
  end

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app
  end
end
```

### Step 3: Implement User Authentication for Admin
We need a way to identify the `current_user` for both the Admin UI and our APIs. Let's add this logic to the main `ApplicationController`.

**File: [`app/controllers/application_controller.rb`](app/controllers/application_controller.rb)**
```ruby
class ApplicationController < ActionController::API
  include JsonWebToken

  before_action :authenticate_request

  private

  def authenticate_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    begin
      @decoded = jwt_decode(header)
      @current_user = User.find(@decoded[:user_id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end

  attr_reader :current_user
end
```

### Step 4: Create Pundit Policies for Admin Access
This policy will check if a user has an admin role before allowing access to the dashboard.

**File: [`app/policies/application_policy.rb`](app/policies/application_policy.rb)** (Modify the generated file)
```ruby
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  # This is the key method for RailsAdmin access.
  # Allow access only to admin roles.
  def access?
    user.present? && (user.super_admin? || user.product_admin? || user.order_admin?)
  end

  # ... other policy methods
end
```
*Note: You can create more granular policies for each model (e.g., `app/policies/product_policy.rb`) to control who can create, update, or delete specific records.*

### Step 5: Implement Supplier Profile API
First, generate a controller for the `SupplierProfile`.

**Command to run:**
```bash
bundle exec rails g controller api/v1/SupplierProfiles show create update
```

Next, add the route for the supplier to manage their own profile. We'll use a singular `resource` for this since a supplier has only one profile.

**File: [`config/routes.rb`](config/routes.rb)** (Add this within the `api/v1` namespace)
```ruby
namespace :api do
  namespace :v1 do
    # ... other routes
    resource :supplier_profile, only: [:show, :create, :update], controller: :supplier_profiles
  end
end
```

### Step 6: Implement Supplier Profile Controller Logic
Add the logic to the controller. We'll ensure only users with the `supplier` role can access this.

**File: [`app/controllers/api/v1/supplier_profiles_controller.rb`](app/controllers/api/v1/supplier_profiles_controller.rb)**
```ruby
class Api::V1::SupplierProfilesController < ApplicationController
  before_action :authorize_supplier!

  def show
    @profile = current_user.supplier_profile
    if @profile
      render json: @profile
    else
      render json: { error: 'Supplier profile not found.' }, status: :not_found
    end
  end

  def create
    @profile = current_user.build_supplier_profile(profile_params)
    if @profile.save
      render json: @profile, status: :created
    else
      render json: { errors: @profile.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @profile = current_user.supplier_profile
    if @profile.update(profile_params)
      render json: @profile
    else
      render json: { errors: @profile.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def authorize_supplier!
    render json: { error: 'Not Authorized' }, status: :unauthorized unless current_user.supplier?
  end

  def profile_params
    params.require(:supplier_profile).permit(:company_name, :gst_number, :description, :website_url)
  end
end
```

---

## Part 2: Supplier Frontend

### Step 1: Create a Protected Route for the Profile Page
In your `supplier-frontend` application, create a page for the supplier profile that requires the user to be logged in.

**Example File Structure:**
- `pages/profile.js`

### Step 2: Build the Profile Management Form
This component will fetch the supplier's current profile and allow them to update it.

**Example Code: `pages/profile.js`**
```javascript
import React, { useState, useEffect } from 'react';

// This is a placeholder for a function that gets the auth token
const getAuthToken = () => localStorage.getItem('token');

const SupplierProfilePage = () => {
  const [profile, setProfile] = useState({
    company_name: '',
    gst_number: '',
    description: '',
    website_url: ''
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchProfile = async () => {
      const token = getAuthToken();
      const response = await fetch('http://localhost:3000/api/v1/supplier_profile', {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (response.ok) {
        const data = await response.json();
        setProfile(data);
      }
      setLoading(false);
    };
    fetchProfile();
  }, []);

  const handleChange = (e) => {
    setProfile({ ...profile, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const token = getAuthToken();
    const response = await fetch('http://localhost:3000/api/v1/supplier_profile', {
      method: 'PUT', // Or 'POST' if creating for the first time
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({ supplier_profile: profile })
    });
    if (response.ok) {
      alert('Profile updated successfully!');
    } else {
      alert('Failed to update profile.');
    }
  };

  if (loading) {
    return <p>Loading...</p>;
  }

  return (
    <form onSubmit={handleSubmit}>
      <h2>My Supplier Profile</h2>
      {/* Add input fields for company_name, gst_number, etc., bound to the 'profile' state */}
      <input
        type="text"
        name="company_name"
        value={profile.company_name}
        onChange={handleChange}
        placeholder="Company Name"
      />
      {/* ... other fields ... */}
      <button type="submit">Save Profile</button>
    </form>
  );
};

export default SupplierProfilePage;
```
This completes Sprint 2. You will have a functional admin dashboard and a page for suppliers to manage their profiles.