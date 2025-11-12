Rails.application.routes.draw do
  # ============================================================================
  # ROOT ROUTE
  # ============================================================================
  root 'admin/dashboard#index'
  
  # ============================================================================
  # RAILS ADMIN ENGINE
  # ============================================================================
  mount RailsAdmin::Engine => '/admin/rails', as: 'rails_admin'
  
  # ============================================================================
  # EMAIL VERIFICATION
  # ============================================================================
  get '/verify-email', to: 'email_verification#show'
  post '/verify-email', to: 'email_verification#verify'
  post '/resend-verification', to: 'email_verification#resend'

  # ============================================================================
  # ADMIN AUTHENTICATION (HTML Interface)
  # ============================================================================
  get '/admin/login', to: 'admin#login', as: 'admin_login'
  post '/admin/login', to: 'admin#login'
  get '/admin/logout', to: 'admin#logout', as: 'admin_logout'
  delete '/admin/logout', to: 'admin#logout'
  
  # ============================================================================
  # INVITATION ACCEPTANCE (Public - No Authentication Required)
  # ============================================================================
  # Admin invitation acceptance
  get '/admin/invitations/accept', to: 'invitations#show', as: 'admin_invitation_accept'
  post '/admin/invitations/accept', to: 'invitations#accept'
  
  # Supplier invitation acceptance
  get '/admin/supplier/invitations/accept', to: 'invitations#show', as: 'supplier_invitation_accept'
  post '/admin/supplier/invitations/accept', to: 'invitations#accept'
  
  # Admin password reset routes
  get '/admin_auth/forgot_password', to: 'verification#forgot_password', as: 'admin_auth_forgot_password'
  post '/admin_auth/forgot_password', to: 'verification#forgot_password'
  get '/admin_auth/reset_password', to: 'verification#reset_password', as: 'admin_auth_reset_password'
  post '/admin_auth/reset_password', to: 'verification#reset_password'
  get '/admin_auth/login_with_temp_password', to: 'verification#login_with_temp_password', as: 'admin_auth_login_with_temp_password'
  post '/admin_auth/login_with_temp_password', to: 'verification#login_with_temp_password'

  # ============================================================================
  # ADMIN NAMESPACE (HTML Interface - Backend Admin Panel)
  # ============================================================================
  namespace :admin do
    root 'dashboard#index'
    get 'dashboard', to: 'dashboard#index', as: 'dashboard'
    
    # Admin management (super admin only)
    resources :admins, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
      collection do
        get :invite
        post :send_invitation
      end
      member do
        patch :block
        patch :unblock
        patch :status, to: 'admins#update_status'
        post :resend_invitation
      end
    end
    
    # User management
    resources :users, only: [:index, :show, :edit, :update, :destroy] do
      member do
        patch :status, to: 'users#update_status'
        get :orders
        get :activity
      end
      collection do
        post :bulk_action
      end
    end
    
    # Supplier management
    resources :suppliers, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
      collection do
        get :invite
        post :send_invitation
        post :bulk_action
      end
      member do
        patch :update_role
        patch :status, to: 'suppliers#update_status'
        patch :suspend
        post :approve
        post :reject
        get :stats
        post :resend_invitation
      end
    end
    
    # Product management
    resources :products, only: [:index, :show, :edit, :update, :destroy] do
      member do
        patch :approve
        patch :reject
      end
      collection do
        post :bulk_approve
        post :bulk_reject
        get :export
      end
    end
    
    # Category management
    resources :categories, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
      collection do
        post :bulk_action
      end
    end
    
    # Order management
    resources :orders, only: [:index, :show, :edit, :update, :destroy] do
      member do
        patch :cancel
        patch :update_status
        post :notes
        get :audit_log
        patch :refund
      end
    end
    
    # Promotions management
    resources :promotions, only: [:index, :show, :new, :create, :edit, :update, :destroy]
    
    # Coupons management
    resources :coupons, only: [:index, :show, :new, :create, :edit, :update, :destroy]
    
    # Reports
    get 'reports', to: 'reports#index', as: 'reports'
    get 'reports/sales', to: 'reports#sales', as: 'reports_sales'
    get 'reports/products', to: 'reports#products', as: 'reports_products'
    
    # Audit Logs (Activity History)
    resources :audit_logs, only: [:index, :show], path: 'activity-history'
    get 'reports/users', to: 'reports#users', as: 'reports_users'
    get 'reports/suppliers', to: 'reports#suppliers', as: 'reports_suppliers'
    get 'reports/revenue', to: 'reports#revenue', as: 'reports_revenue'
    get 'reports/returns', to: 'reports#returns', as: 'reports_returns'
    get 'reports/export', to: 'reports#export', as: 'reports_export'
    
    # Settings (super admin only)
    resources :settings, only: [:index, :show, :new, :create, :edit, :update, :destroy]
    
    # System Configurations
    resources :system_configurations, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
      member do
        patch :activate
        patch :deactivate
      end
    end
    
    # Email Templates (super admin only)
    resources :email_templates, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
      member do
        post :preview
      end
    end
    
    # Navigation Items Management (super admin only)
    resources :navigation_items, only: [:index, :show, :new, :create, :edit, :update, :destroy]
    
    # RBAC Roles & Permissions Management (super admin only)
    resources :rbac_roles, only: [:index, :show, :edit, :update], path: 'roles-permissions' do
      member do
        post :assign_to_admin
        delete :remove_from_admin
      end
    end
  end

  # ============================================================================
  # API V1 NAMESPACE
  # ============================================================================
  namespace :api do
    namespace :v1 do
      # ------------------------------------------------------------------------
      # Authentication
      # ------------------------------------------------------------------------
      post 'signup', to: 'users#create'
      post 'login', to: 'authentication#create'
      delete 'logout', to: 'authentication#destroy'
      post 'password/forgot', to: 'password_reset#forgot'
      post 'password/reset', to: 'password_reset#reset'

      # ------------------------------------------------------------------------
      # Users
      # ------------------------------------------------------------------------
      resources :users, only: [:show, :update, :destroy] do
        collection do
          get 'me', to: 'users#me'
          post 'bulk_delete', to: 'users#bulk_delete'
        end
      end
      
      # User Profile & Activity
      namespace :user do
        get 'statistics', to: 'statistics#index'
        get 'activity', to: 'activity#index'
        resources :searches, only: [:index, :create, :destroy], controller: 'user_searches' do
          collection do
            delete 'clear', to: 'user_searches#clear'
            get 'popular', to: 'user_searches#popular'
          end
        end
      end
      
      # Referrals
      resources :referrals, only: [:index] do
        collection do
          get 'code', to: 'referrals#code'
          get 'stats', to: 'referrals#stats'
        end
      end
      
      # Email Verification
      scope :email, controller: 'email_verification' do
        get 'verify', action: 'verify'
        post 'resend', action: 'resend'
        post 'resend_authenticated', action: 'resend_authenticated'
        get 'status', action: 'status'
      end

      # ------------------------------------------------------------------------
      # Supplier Profile & Documents
      # ------------------------------------------------------------------------
      resource :supplier_profile, only: [:show, :create, :update], controller: :supplier_profiles
      
      namespace :supplier do
        resources :documents, only: [:index, :create, :destroy], controller: 'supplier_documents'
      end

      # ------------------------------------------------------------------------
      # Products
      # ------------------------------------------------------------------------
      resources :products, only: [:index, :show, :create, :update, :destroy], controller: :products do
        resources :product_variants, only: [:create, :update, :destroy]
        resources :reviews, only: [:create, :index] do
          member do
            post :vote
          end
        end
        member do
          post :views, to: 'product_views#track'
        end
      end
      
      # Product bulk operations
      post 'products/bulk_upload', to: 'product_bulk_operations#bulk_upload'
      get 'products/export', to: 'product_bulk_operations#export'
      get 'products/export_template', to: 'product_bulk_operations#export_template'

      # Public Products (no authentication required)
      get 'public/products', to: 'public_products#index'
      get 'public/products/:id', to: 'public_products#show'

      # ------------------------------------------------------------------------
      # Categories, Brands & Attributes
      # ------------------------------------------------------------------------
      resources :categories, only: [:index, :show] do
        collection do
          get :navigation
        end
      end
      resources :brands, only: [:index, :show]
      resources :attribute_types, only: [:index]

      # ------------------------------------------------------------------------
      # Search
      # ------------------------------------------------------------------------
      get 'search', to: 'search#search'

      # ------------------------------------------------------------------------
      # Cart
      # ------------------------------------------------------------------------
      resource :cart, only: [:show], controller: :carts
      resources :cart_items, only: [:create, :update, :destroy]

      # ------------------------------------------------------------------------
      # Wishlist
      # ------------------------------------------------------------------------
      namespace :wishlist do
        resources :items, only: [:index, :create, :destroy], controller: 'wishlist_items'
      end

      # ------------------------------------------------------------------------
      # Addresses
      # ------------------------------------------------------------------------
      resources :addresses, only: [:index, :create, :update, :destroy]

      # ------------------------------------------------------------------------
      # Orders (Customer)
      # ------------------------------------------------------------------------
      resources :orders, only: [:create, :show, :index] do
        member do
          get :invoice
          patch :cancel
        end
      end
      # Alias routes for clarity
      get 'my-orders', to: 'orders#index'
      get 'my-orders/:id', to: 'orders#show'
      get 'my-orders/:id/invoice', to: 'orders#invoice'
      patch 'my-orders/:id/cancel', to: 'orders#cancel'

      # ------------------------------------------------------------------------
      # Supplier Orders
      # ------------------------------------------------------------------------
      namespace :supplier do
        get 'orders', to: 'supplier_orders#index'
        get 'orders/:item_id', to: 'supplier_orders#show'
        post 'orders/:item_id/confirm', to: 'supplier_orders#confirm'
        put 'orders/:item_id/ship', to: 'supplier_orders#ship'
        put 'orders/:item_id/update_tracking', to: 'supplier_orders#update_tracking'
      end

      # ------------------------------------------------------------------------
      # Returns
      # ------------------------------------------------------------------------
      resources :return_requests, only: [:create, :index, :show] do
        member do
          get :tracking
          post :pickup_schedule
        end
      end
      get 'my-returns', to: 'return_requests#index'

      # Supplier Returns
      namespace :supplier do
        get 'returns', to: 'supplier_returns#index'
        get 'returns/:id', to: 'supplier_returns#show'
        get 'returns/:id/tracking', to: 'supplier_returns#tracking'
        post 'returns/:id/approve', to: 'supplier_returns#approve'
        post 'returns/:id/reject', to: 'supplier_returns#reject'
      end

      # ------------------------------------------------------------------------
      # Payments
      # ------------------------------------------------------------------------
      resources :orders, only: [] do
        resources :payments, only: [:create], controller: 'payments'
      end
      resources :payments, only: [:show] do
        member do
          post :refund
        end
      end
      resources :payment_refunds, only: [:index, :show, :create]

      # ------------------------------------------------------------------------
      # Shipping
      # ------------------------------------------------------------------------
      resources :shipping_methods, only: [:index]
      resources :orders, only: [] do
        resources :shipments, only: [:index], controller: 'shipments'
      end
      resources :shipments, only: [:show] do
        member do
          get :tracking
        end
      end

      # Supplier Shipping
      namespace :supplier do
        resources :shipments, only: [:index, :create, :show], controller: 'shipments' do
          member do
            post :tracking_events
          end
        end
      end

      # ------------------------------------------------------------------------
      # Coupons & Promotions
      # ------------------------------------------------------------------------
      get 'coupons/validate', to: 'coupons#validate'
      post 'coupons/apply', to: 'coupons#apply'
      resources :promotions, only: [:index, :show]

      # ------------------------------------------------------------------------
      # Notifications
      # ------------------------------------------------------------------------
      resources :notifications, only: [:index, :show] do
        member do
          patch :mark_as_read
        end
        collection do
          patch :mark_all_read
          get :unread_count
        end
      end
      resource :notification_preferences, only: [:show, :update]

      # ------------------------------------------------------------------------
      # Support Tickets
      # ------------------------------------------------------------------------
      resources :support_tickets, only: [:index, :show, :create] do
        resources :messages, only: [:create], controller: 'support_ticket_messages'
      end

      # ------------------------------------------------------------------------
      # Loyalty Points
      # ------------------------------------------------------------------------
      resources :loyalty_points, only: [:index] do
        collection do
          get :balance
        end
      end

      # ------------------------------------------------------------------------
      # Supplier Payments & Analytics
      # ------------------------------------------------------------------------
      namespace :supplier do
        get 'payments', to: 'supplier_payments#index'
        get 'payments/:id', to: 'supplier_payments#show'
        patch 'reviews/:id/respond', to: 'reviews#supplier_respond'
        get 'analytics', to: 'supplier_analytics#index'
        
        # Supplier Team Management (suppliers inviting other suppliers)
        resources :users, only: [:index, :show, :create, :update, :destroy], controller: 'users' do
          collection do
            post :invite
          end
          member do
            post :resend_invitation
          end
        end
      end

      # ------------------------------------------------------------------------
      # ADMIN API ENDPOINTS
      # ------------------------------------------------------------------------
      namespace :admin do
        post 'login', to: 'authentication#create'
        delete 'logout', to: 'authentication#destroy'
        get 'me', to: 'authentication#me'
        get 'search', to: 'search#search'
        
        # Admin management (super admin only)
        resources :admins, only: [:index, :show, :update, :destroy] do
          member do
            patch :block
            patch :unblock
            patch :status, to: 'admins#update_status'
          end
        end
        
        # User management
        resources :users, only: [:index, :show, :update, :destroy] do
          member do
            patch :status, to: 'users#update_status'
            get :orders
            get :activity
          end
        end
        
        # Supplier management
        resources :suppliers, only: [:index, :show, :update, :destroy] do
          collection do
            post :invite
          end
          member do
            patch :status, to: 'suppliers#update_status'
            patch :suspend
            get :stats
            post :resend_invitation
          end
        end
        
        # Product management
        resources :products, only: [:index, :show, :update, :destroy] do
          member do
            patch :approve
            patch :reject
          end
          collection do
            post :bulk_approve
            post :bulk_reject
            get :export
          end
        end
        
        # Order management
        resources :orders, only: [:index, :show, :update, :destroy] do
          member do
            patch :cancel
            patch :update_status
            post :notes, to: 'orders#add_note'
            get :audit_log
            patch :refund
          end
        end
        
        # Reports & Analytics
        get 'reports/sales', to: 'reports#sales'
        get 'reports/products', to: 'reports#products'
        get 'reports/users', to: 'reports#users'
        get 'reports/suppliers', to: 'reports#suppliers'
        get 'reports/revenue', to: 'reports#revenue'
        get 'reports/returns', to: 'reports#returns'
        get 'reports/export', to: 'reports#export'
        
        # System Settings
        get 'settings', to: 'settings#index'
        get 'settings/:key', to: 'settings#show'
        post 'settings', to: 'settings#create'
        patch 'settings/:id', to: 'settings#update'
        delete 'settings/:id', to: 'settings#destroy'
        
        # Email Templates
        resources :email_templates, only: [:index, :show, :create, :update, :destroy] do
          member do
            post :preview
          end
        end
        
        # Supplier Payments (Admin view) - routes to Api::V1::SupplierPaymentsController
        get 'supplier_payments', to: 'supplier_payments#admin_index', controller: 'supplier_payments'
        post 'supplier_payments', to: 'supplier_payments#admin_create', controller: 'supplier_payments'
        get 'supplier_payments/:id', to: 'supplier_payments#show', controller: 'supplier_payments'
        
        # Shipping Methods (Admin management) - routes to Api::V1::ShippingMethodsController
        get 'shipping_methods', to: 'shipping_methods#admin_index', controller: 'shipping_methods'
        post 'shipping_methods', to: 'shipping_methods#admin_create', controller: 'shipping_methods'
        patch 'shipping_methods/:id', to: 'shipping_methods#admin_update', controller: 'shipping_methods'
        delete 'shipping_methods/:id', to: 'shipping_methods#admin_destroy', controller: 'shipping_methods'
        
        # Coupons (Admin management) - routes to Api::V1::CouponsController
        get 'coupons', to: 'coupons#admin_index', controller: 'coupons'
        post 'coupons', to: 'coupons#admin_create', controller: 'coupons'
        patch 'coupons/:id', to: 'coupons#admin_update', controller: 'coupons'
        delete 'coupons/:id', to: 'coupons#admin_destroy', controller: 'coupons'
        
        # Promotions (Admin management) - routes to Api::V1::PromotionsController
        get 'promotions', to: 'promotions#admin_index', controller: 'promotions'
        post 'promotions', to: 'promotions#admin_create', controller: 'promotions'
        patch 'promotions/:id', to: 'promotions#admin_update', controller: 'promotions'
        delete 'promotions/:id', to: 'promotions#admin_destroy', controller: 'promotions'
        
        # Review Moderation - routes to Api::V1::ReviewsController
        patch 'reviews/:id/moderate', to: 'reviews#admin_moderate', controller: 'reviews'
        
        # Return Requests (Admin) - routes to Api::V1::ReturnRequestsController
        patch 'return_requests/:id/approve', to: 'return_requests#admin_approve', controller: 'return_requests'
        patch 'return_requests/:id/reject', to: 'return_requests#admin_reject', controller: 'return_requests'
        patch 'return_requests/:id/process_refund', to: 'return_requests#admin_process_refund', controller: 'return_requests'
        
        # Support Tickets (Admin) - routes to Api::V1::SupportTicketsController
        get 'support_tickets', to: 'support_tickets#admin_index', controller: 'support_tickets'
        get 'support_tickets/:id', to: 'support_tickets#admin_show', controller: 'support_tickets'
        patch 'support_tickets/:id/assign', to: 'support_tickets#admin_assign', controller: 'support_tickets'
        patch 'support_tickets/:id/resolve', to: 'support_tickets#admin_resolve', controller: 'support_tickets'
        patch 'support_tickets/:id/close', to: 'support_tickets#admin_close', controller: 'support_tickets'
        
        # RBAC Management (SuperAdmin only)
        namespace :rbac do
          get 'roles', to: 'rbac#roles'
          get 'permissions', to: 'rbac#permissions'
          get 'admins/:id/roles', to: 'rbac#admin_roles'
          post 'admins/:id/assign_role', to: 'rbac#assign_role'
          delete 'admins/:id/remove_role/:role_slug', to: 'rbac#remove_role'
          patch 'admins/:id/update_permissions', to: 'rbac#update_permissions'
        end
      end
    end
  end

  # ============================================================================
  # HEALTH CHECK
  # ============================================================================
  get "up" => "rails/health#show", as: :rails_health_check
  
  # ============================================================================
  # CATCH-ALL ROUTE (404 Handler)
  # ============================================================================
  # This must be last - catches any unmatched routes for HTML requests
  # Note: API routes will be handled by ApplicationController
  get '*path', to: 'admin#route_not_found', constraints: lambda { |req|
    req.format.html? && !req.path.start_with?('/rails') && !req.path.start_with?('/assets')
  }
end
