Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  
  # Admin authentication routes
  get '/admin/login', to: 'admin#login'
  post '/admin/authenticate', to: 'admin#authenticate'
  get '/admin/logout', to: 'admin#logout'

  namespace :api do
    namespace :v1 do
      post 'signup', to: 'users#create'
      post 'login', to: 'authentication#create'

      resource :supplier_profile, only: [:show, :create, :update], controller: :supplier_profiles

      resources :products, only: [:index, :show, :create, :update, :destroy] do
        resources :product_variants, only: [:create, :update, :destroy]
        resources :reviews, only: [:create, :index]
      end

      resources :categories, only: [:index]
      resources :brands, only: [:index]
      get 'search', to: 'search#search'

      resource :cart, only: [:show], controller: :carts
      resources :cart_items, only: [:create, :update, :destroy]

      resources :addresses, only: [:index, :create, :update, :destroy]
      resources :orders, only: [:create, :show, :index]

      get 'supplier/orders', to: 'supplier_orders#index'

      resources :return_requests, only: [:create, :index, :show]
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
