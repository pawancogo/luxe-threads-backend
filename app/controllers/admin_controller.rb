class AdminController < BaseController
  before_action :authenticate_admin!, except: [:login]
  before_action :set_current_admin, except: [:login]

  def dashboard
    # Dashboard access is already controlled by authenticate_admin! before_action
    @admins_count = ::Admin.count
    @users_count = User.count
    @suppliers_count = User.where(role: 'supplier').count
    @products_count = Product.count
    @orders_count = Order.count
    
    # Phase 2: Additional metrics
    @active_products_count = Product.where(status: 'active').count
    @featured_products_count = Product.where(is_featured: true).count
    @low_stock_variants_count = ProductVariant.where(is_low_stock: true).count
    @out_of_stock_variants_count = ProductVariant.where(out_of_stock: true).count
    @pending_orders_count = Order.where(status: 'pending').count
    @shipped_orders_count = Order.where(status: 'shipped').count
    @categories_count = Category.count
    @brands_count = Brand.where(active: true).count
    
    @recent_orders = Order.includes(:user).order(created_at: :desc).limit(5)
    @recent_users = User.order(created_at: :desc).limit(5)
    
    # Phase 2: Recent products with Phase 2 fields
    @recent_products = Product.includes(:supplier_profile, :category, :brand)
                              .order(created_at: :desc)
                              .limit(5)
  end

  def login
    if request.post?
      admin = ::Admin.find_by(email: params[:email])
      
      if admin&.authenticate(params[:password])
        session[:admin_id] = admin.id
        redirect_to admin_root_path, notice: 'Successfully logged in!'
      else
        flash.now[:alert] = 'Invalid email or password'
        render :login, layout: false
      end
    else
      render :login, layout: false
    end
  end

  def logout
    session[:admin_id] = nil
    redirect_to admin_login_path, notice: 'Successfully logged out!'
  end

  def route_not_found
    render html: <<~HTML.html_safe, status: :not_found, layout: false
      <!DOCTYPE html>
      <html>
      <head>
        <title>404 - Page Not Found</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <style>
          body { display: flex; align-items: center; justify-content: center; min-height: 100vh; background: #f8f9fa; }
        </style>
      </head>
      <body>
        <div class="text-center">
          <h1 class="display-1">404</h1>
          <h2>Page Not Found</h2>
          <p class="text-muted">The page you're looking for doesn't exist.</p>
          <a href="/admin" class="btn btn-primary">Go to Admin Dashboard</a>
        </div>
      </body>
      </html>
    HTML
  end

  private

  def authenticate_admin!
    unless current_admin
      redirect_to admin_login_path, alert: 'Please log in to access admin panel'
    end
  end

  def current_admin
    @current_admin ||= ::Admin.find(session[:admin_id]) if session[:admin_id]
  rescue ActiveRecord::RecordNotFound
    session[:admin_id] = nil
    nil
  end

  def set_current_admin
    @current_admin = current_admin
  end

  helper_method :current_admin
end
