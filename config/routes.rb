Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  
  # Email verification routes
  get '/verify-email', to: 'email_verification#show'
  post '/verify-email', to: 'email_verification#verify'
  post '/resend-verification', to: 'email_verification#resend'

  # Admin authentication routes (before RailsAdmin mount)
  get '/admin_auth', to: 'admin#login', as: 'admin_root'
  get '/admin_auth/login', to: 'admin#login', as: 'admin_login'
  post '/admin_auth/login', to: 'admin#login'
  delete '/admin_auth/logout', to: 'admin#logout', as: 'admin_logout'
  get '/admin_auth/logout', to: 'admin#logout'
  get '/admin_auth/dashboard', to: 'admin#dashboard', as: 'admin_dashboard'
  
  # Generic verification routes for all user types
  %w[admin user supplier].each do |user_type|
    get "/#{user_type}_auth/login_with_temp_password", to: 'verification#login_with_temp_password', as: "#{user_type}_login_with_temp_password"
    post "/#{user_type}_auth/login_with_temp_password", to: 'verification#login_with_temp_password'
    get "/#{user_type}_auth/reset_password", to: 'verification#reset_password', as: "#{user_type}_reset_password"
    post "/#{user_type}_auth/reset_password", to: 'verification#reset_password'
    get "/#{user_type}_auth/forgot_password", to: 'verification#forgot_password', as: "#{user_type}_forgot_password"
    post "/#{user_type}_auth/forgot_password", to: 'verification#forgot_password'
  end
  
  # Admin namespace routes
  namespace :admin do
    
    # Admin management routes (super admin only)
    resources :admins, only: [:index, :show, :new, :create, :edit, :update, :destroy]
    
    # Supplier management routes (super admin only)
    resources :suppliers, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
      member do
        patch :update_role
        post :approve
        post :reject
      end
    end
    
    # Product approval routes (product admin or super admin)
    resources :products, only: [:index, :show] do
      member do
        post :approve
        post :reject
      end
    end
  end

  namespace :api do
    namespace :v1 do
      # Authentication
      post 'signup', to: 'users#create'
      post 'login', to: 'authentication#create'

      # Supplier Profile
      resource :supplier_profile, only: [:show, :create, :update], controller: :supplier_profiles

      # Supplier Products (authenticated suppliers only)
      resources :products, only: [:index, :show, :create, :update, :destroy], controller: :products do
        resources :product_variants, only: [:create, :update, :destroy]
        resources :reviews, only: [:create, :index]
      end

      # Public Products (for customers, no authentication required)
      get 'public/products', to: 'public_products#index'
      get 'public/products/:id', to: 'public_products#show'

      # Categories and Brands
      resources :categories, only: [:index]
      resources :brands, only: [:index]
      
      # Attribute Types (for product variants - Color, Size, Fabric, etc.)
      resources :attribute_types, only: [:index]
      
      # Search
      get 'search', to: 'search#search'

      # Cart
      resource :cart, only: [:show], controller: :carts
      resources :cart_items, only: [:create, :update, :destroy]

      # Wishlist
      namespace :wishlist do
        resources :items, only: [:index, :create, :destroy], controller: 'wishlist_items'
      end

      # Addresses
      resources :addresses, only: [:index, :create, :update, :destroy]

      # Orders (customer)
      resources :orders, only: [:create, :show, :index]
      get 'my-orders', to: 'orders#index'
      get 'my-orders/:id', to: 'orders#show'

      # Supplier Orders
      get 'supplier/orders', to: 'supplier_orders#index'
      get 'supplier/orders/:item_id', to: 'supplier_orders#show'
      put 'supplier/orders/:item_id/ship', to: 'supplier_orders#ship'

      # Returns
      resources :return_requests, only: [:create, :index, :show]
      get 'my-returns', to: 'return_requests#index'
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
