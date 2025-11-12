class Admin::DashboardController < Admin::BaseController
  def index
    start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : nil
    end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : nil
    
    service = Admins::DashboardService.new(start_date: start_date, end_date: end_date)
    service.call
    
    if service.success?
      result = service.result
      @stats = result[:stats]
      @revenue_metrics = result[:revenue_metrics]
      @daily_revenue = result[:daily_revenue]
      @revenue_by_category = result[:revenue_by_category]
      @recent_orders = result[:recent_orders]
      @recent_products = result[:recent_products]
      @recent_users = result[:recent_users]
      
      # All orders for the orders table
      @orders = Order.includes(:user)
                     .order(created_at: :desc)
                     .page(params[:page])
    else
      flash[:alert] = service.errors.join(', ')
      redirect_to admin_root_path
    end
  end
end


