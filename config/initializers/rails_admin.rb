RailsAdmin.config do |config|
  config.asset_source = :sprockets

  ### Popular gems integration

  ## == Authentication ==
  config.authenticate_with do
    unless session[:admin_id] && Admin.find_by(id: session[:admin_id])
      redirect_to '/admin_auth/login', alert: 'Please log in to access admin panel'
    end
  end
  
  config.current_user_method do
    if session[:admin_id]
      Admin.find_by(id: session[:admin_id])
    else
      nil
    end
  rescue ActiveRecord::RecordNotFound
    session[:admin_id] = nil
    nil
  end

  ## == CancanCan ==
  # config.authorize_with :cancancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/railsadminteam/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete do
      # Restrict bulk_delete action to super_admin only for User model
      visible do
        begin
          model_name = bindings[:abstract_model]&.model&.name || bindings[:object]&.class&.name
          if model_name == 'User'
            current_admin = bindings[:view]._current_user
            current_admin&.super_admin? == true
          else
            true  # Allow bulk_delete for other models
          end
        rescue
          true  # Fallback: allow bulk_delete if we can't determine
        end
      end
    end
    show
    edit
    delete do
      # Restrict delete action to super_admin only for User model
      # This will cascade delete all associated records (orders, addresses, cart, wishlist, etc.)
      # via the User model's handle_dependent_deletions callback
      visible do
        # Only show delete button for User model if current admin is super_admin
        begin
          model_name = bindings[:abstract_model]&.model&.name || bindings[:object]&.class&.name
          if model_name == 'User'
            current_admin = bindings[:view]._current_user
            current_admin&.super_admin? == true
          else
            true  # Allow delete for other models
          end
        rescue
          true  # Fallback: allow delete if we can't determine
        end
      end
    end
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  # Customize the dashboard - Users (Customers & Suppliers)
  config.model 'User' do
    list do
      # Show all users by default (customers and suppliers)
      # Use scope dropdown to filter: customers_only, suppliers_only, or all
      # First scope in array becomes the default
      scopes [:all, :customers_only, :suppliers_only]
      
      field :id
      field :first_name
      field :last_name
      field :email
      field :role
      field :phone_number
      field :created_at
      field :last_login_at
    end
    
    edit do
      field :first_name
      field :last_name
      field :email
      field :phone_number
      field :role
      field :password
      field :password_confirmation
    end
    
    
    # Delete action is restricted in the actions block above
    # When a super_admin deletes a user, it will cascade delete all associated records
    # (orders, addresses, cart, wishlist, etc.) via the User model's handle_dependent_deletions callback
  end

  config.model 'Product' do
    list do
      field :id
      field :name
      field :slug
      field :supplier_profile do
        label 'Supplier'
      end
      field :category
      field :brand
      field :status
      # Phase 2 fields
      field :is_featured
      field :is_bestseller
      field :is_new_arrival
      field :is_trending
      field :total_stock_quantity do
        label 'Total Stock'
      end
      field :created_at
    end
    
    edit do
      field :name
      field :slug
      field :description
      field :short_description
      field :supplier_profile do
        label 'Supplier'
      end
      field :category
      field :brand
      field :product_type
      field :status
      # Phase 2: SEO fields
      field :meta_title
      field :meta_description
      field :meta_keywords
      # Phase 2: Flags
      field :is_featured
      field :is_bestseller
      field :is_new_arrival
      field :is_trending
      field :published_at
      # Phase 2: Dimensions
      field :length_cm
      field :width_cm
      field :height_cm
      field :weight_kg
      field :verified_by_admin do
        label 'Verified By'
      end
      field :verified_at
    end
  end

  # Phase 2: Category configuration
  config.model 'Category' do
    list do
      field :id
      field :name
      field :slug
      field :parent
      field :level
      field :featured
      field :products_count
      field :active_products_count
      field :created_at
    end
    
    edit do
      field :name
      field :slug
      field :parent
      field :short_description
      field :image_url
      field :banner_url
      field :icon_url
      field :featured
      field :sort_order
      # Phase 2: SEO fields
      field :meta_title
      field :meta_description
      field :meta_keywords
    end
  end

  # Phase 2: Brand configuration
  config.model 'Brand' do
    list do
      field :id
      field :name
      field :slug
      field :active
      field :products_count
      field :active_products_count
      field :created_at
    end
    
    edit do
      field :name
      field :slug
      field :logo_url
      field :banner_url
      field :short_description
      field :country_of_origin
      field :founded_year
      field :website_url
      field :active
      # Phase 2: SEO fields
      field :meta_title
      field :meta_description
    end
  end

  # Phase 2: ProductVariant configuration
  config.model 'ProductVariant' do
    list do
      field :id
      field :sku
      field :product
      field :price
      field :discounted_price
      field :stock_quantity
      field :available_quantity do
        label 'Available'
      end
      field :is_available
      field :is_low_stock
      field :out_of_stock
      field :created_at
    end
    
    edit do
      field :product
      field :sku
      field :price
      field :discounted_price
      field :mrp
      field :cost_price
      field :currency
      field :stock_quantity
      field :reserved_quantity
      field :available_quantity
      field :low_stock_threshold
      field :barcode
      field :ean_code
      field :isbn
      field :weight_kg
    end
  end

  config.model 'Order' do
    list do
      field :id
      field :order_number
      field :user do
        label 'Customer'
      end
      field :status
      field :payment_status
      field :total_amount
      field :currency
      field :tracking_number
      field :created_at
    end
    
    edit do
      field :order_number
      field :user do
        label 'Customer'
      end
      field :status
      field :payment_status
      field :total_amount
      field :currency
      field :tax_amount
      field :coupon_discount
      field :shipping_method
      field :tracking_number
      field :tracking_url
      field :estimated_delivery_date
      field :actual_delivery_date
      field :customer_notes
      field :internal_notes
    end
  end

  # Phase 2: OrderItem configuration
  config.model 'OrderItem' do
    list do
      field :id
      field :order
      field :product_name
      field :supplier_profile do
        label 'Supplier'
      end
      field :quantity
      field :final_price
      field :fulfillment_status
      field :tracking_number
      field :created_at
    end
    
    edit do
      field :order
      field :product_variant
      field :supplier_profile do
        label 'Supplier'
      end
      field :quantity
      field :price_at_purchase
      field :discounted_price
      field :final_price
      field :currency
      field :fulfillment_status
      field :tracking_number
      field :tracking_url
      field :shipped_at
      field :delivered_at
      field :is_returnable
      field :return_deadline
    end
  end

  # Supplier model removed - suppliers are now Users with role='supplier'
  # Use User model with supplier role filter instead
  
  # Navigation grouping for Users & Suppliers
  config.model 'User' do
    navigation_label 'Users & Suppliers'
    weight 1
  end

  config.model 'SupplierProfile' do
    navigation_label 'Users & Suppliers'
    weight 2
    list do
      field :id
      field :company_name
      field :owner do
        label 'Owner'
      end
      field :user do
        label 'User (Legacy)'
      end
      field :supplier_tier
      field :verified
      field :is_active
      field :created_at
    end
    
    edit do
      field :company_name
      field :gst_number
      field :owner
      field :supplier_tier
      field :verified
      field :is_active
      field :is_suspended
    end
  end

end
