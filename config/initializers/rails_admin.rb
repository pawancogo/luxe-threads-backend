RailsAdmin.config do |config|
  config.asset_source = :sprockets

  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)

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

end
