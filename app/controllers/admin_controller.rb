class AdminController < BaseController
  before_action :authenticate_admin!, except: [:login]
  before_action :set_current_admin, except: [:login]

  def dashboard
    # Dashboard access is already controlled by authenticate_admin! before_action
    @admins_count = Admin.count
    @users_count = User.count
    @suppliers_count = Supplier.count
    @products_count = Product.count
    @orders_count = Order.count
    @recent_orders = Order.includes(:user).order(created_at: :desc).limit(5)
    @recent_users = User.order(created_at: :desc).limit(5)
  end

  def login
    if request.post?
      admin = Admin.find_by(email: params[:email])
      
      if admin&.authenticate(params[:password])
        session[:admin_id] = admin.id
        redirect_to admin_dashboard_path, notice: 'Successfully logged in!'
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

  private

  def authenticate_admin!
    unless current_admin
      redirect_to admin_login_path
    end
  end

  def current_admin
    @current_admin ||= Admin.find(session[:admin_id]) if session[:admin_id]
  rescue ActiveRecord::RecordNotFound
    session[:admin_id] = nil
    nil
  end

  def set_current_admin
    @current_admin = current_admin
  end

  helper_method :current_admin
end
