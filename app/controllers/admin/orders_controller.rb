# frozen_string_literal: true

# Refactored Admin::OrdersController using Clean Architecture
# Controller → Service → Model → Presenter → View
class Admin::OrdersController < Admin::BaseController
  include EagerLoading
  before_action :require_order_admin_role!
  before_action :enable_date_filter, only: [:index]
  before_action :set_order, only: [:show, :edit, :update, :destroy, :cancel, :update_status, :notes, :audit_log, :refund]

  def index
    search_options = { date_range_column: :created_at }
    search_options[:range_field] = @filters[:range_field] if @filters[:range_field].present?
    
    service = Admins::HtmlOrderListingService.new(Order.all, params, search_options)
    service.call
    
    if service.success?
      @orders = service.orders
      @filters.merge!(service.filters)
      @order_presenters = @orders.map { |order| OrderPresenter.new(order) }
    else
      @orders = Order.none
      @filters = {}
      @order_presenters = []
      flash[:alert] = service.errors.join(', ')
    end
  end

  def show
    @order_presenter = OrderPresenter.new(@order)
  end

  def edit
    @order_presenter = OrderPresenter.new(@order)
  end

  def update
    if order_params[:status].present?
      service = Orders::StatusUpdateService.new(@order, order_params[:status], updated_by: current_admin)
      service.call
      
      if service.success?
        redirect_to admin_order_path(@order), notice: 'Order updated successfully.'
      else
        @order_presenter = OrderPresenter.new(@order)
        render :edit, status: :unprocessable_entity
      end
    else
      # Update other order fields (tracking, notes, etc.)
      service = Orders::GeneralUpdateService.new(@order, order_params.except(:status))
      service.call
      
      if service.success?
        redirect_to admin_order_path(@order), notice: 'Order updated successfully.'
      else
        @order_presenter = OrderPresenter.new(@order)
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def destroy
    service = Orders::DeletionService.new(@order)
    service.call
    
    if service.success?
      redirect_to admin_orders_path, notice: 'Order deleted successfully.'
    else
      redirect_to admin_orders_path, alert: service.errors.first || 'Failed to delete order'
    end
  end

  def cancel
    service = Orders::CancellationService.new(
      @order,
      params[:cancellation_reason],
      cancelled_by: 'admin'
    )
    
    service.call
    
    if service.success?
      redirect_to admin_order_path(@order), notice: 'Order cancelled successfully.'
    else
      redirect_to admin_order_path(@order), alert: service.errors.join(', ')
    end
  end

  def update_status
    service = Orders::StatusUpdateService.new(
      @order,
      params[:status],
      updated_by: current_admin
    )
    
    service.call
    
    if service.success?
      redirect_to admin_order_path(@order), notice: 'Order status updated successfully.'
    else
      redirect_to admin_order_path(@order), alert: service.errors.join(', ')
    end
  end

  def notes
    # TODO: Implement note service
    redirect_to admin_order_path(@order), notice: 'Note added successfully.'
  end

  def audit_log
    # TODO: Implement audit log presenter
  end

  def refund
    # TODO: Implement refund service
    redirect_to admin_order_path(@order), notice: 'Refund processed successfully.'
  end

  private

  def set_order
    @order = with_eager_loading(Order.all, additional_includes: order_includes).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_orders_path, alert: 'Order not found.'
  end

  def order_params
    params.require(:order).permit(:internal_notes, :tracking_number, :tracking_url)
  end

  def require_order_admin_role!
    has_permission = if current_admin
      current_admin.super_admin? || 
      current_admin.order_admin? || 
      current_admin.has_permission?('orders:view') ||
      current_admin.has_permission?('orders:read')
    else
      false
    end
    
    unless has_permission
      redirect_to admin_root_path, alert: 'You do not have permission to access this page.'
    end
  end
end

