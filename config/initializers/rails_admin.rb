RailsAdmin.config do |config|
  config.asset_source = :sprockets

  ### Popular gems integration

  ## == Authentication ==
  config.authenticate_with do
    # Custom authentication for Rails Admin
    # We'll use JWT token from session or header
    if session[:admin_user_id]
      @current_admin_user = User.find(session[:admin_user_id])
    elsif request.headers['Authorization']
      token = request.headers['Authorization'].split(' ').last
      begin
        decoded = JWT.decode(token, Rails.application.secret_key_base)[0]
        @current_admin_user = User.find(decoded['user_id'])
      rescue JWT::DecodeError, ActiveRecord::RecordNotFound
        @current_admin_user = nil
      end
    end
    
    # Only allow admin users
    if @current_admin_user&.admin?
      @current_admin_user
    else
      redirect_to '/api/v1/login' and return
    end
  end
  
  config.current_user_method do
    @current_admin_user
  end

  ## == Pundit Authorization ==
  config.authorize_with :pundit

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
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  # Customize the dashboard
  config.model 'User' do
    list do
      field :id
      field :first_name
      field :last_name
      field :email
      field :role
      field :created_at
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
  end

  config.model 'Product' do
    list do
      field :id
      field :name
      field :supplier_profile do
        label 'Supplier'
      end
      field :category
      field :brand
      field :status
      field :created_at
    end
    
    edit do
      field :name
      field :description
      field :supplier_profile do
        label 'Supplier'
      end
      field :category
      field :brand
      field :status
      field :verified_by_admin do
        label 'Verified By'
      end
      field :verified_at
    end
  end

  config.model 'Order' do
    list do
      field :id
      field :user do
        label 'Customer'
      end
      field :status
      field :payment_status
      field :total_amount
      field :created_at
    end
  end

  config.model 'SupplierProfile' do
    list do
      field :id
      field :company_name
      field :user do
        label 'Owner'
      end
      field :verified
      field :created_at
    end
  end

  # Add custom actions for product verification
  config.model 'Product' do
    member :approve_product do
      visible? { bindings[:object].is_a?(Product) && bindings[:object].pending? }
      link_icon 'icon-check'
      pjax false
      action :post do
        bindings[:object].update(
          status: :active, 
          verified_by_admin_id: bindings[:view]._current_user.id, 
          verified_at: Time.current
        )
        redirect_to back_or_index, notice: 'Product approved successfully.'
      end
    end

    member :reject_product do
      visible? { bindings[:object].is_a?(Product) && bindings[:object].pending? }
      link_icon 'icon-remove'
      pjax false
      action :post do
        bindings[:object].update(
          status: :rejected, 
          verified_by_admin_id: bindings[:view]._current_user.id, 
          verified_at: Time.current
        )
        redirect_to back_or_index, notice: 'Product rejected successfully.'
      end
    end
  end
end
