# frozen_string_literal: true

class Admin::OrdersController < Admin::BaseController
    before_action :require_order_admin_role!
    before_action :enable_date_filter, only: [:index]
    before_action :set_order, only: [:show, :edit, :update, :destroy, :cancel, :update_status, :notes, :audit_log, :refund]

    def index
      @orders = Order.includes(:user)._search(params, date_range_column: :created_at).order(created_at: :desc)
      @filters.merge!(@orders.filter_with_aggs)
    end

    def show
    end

    def edit
    end

    def update
      if @order.update(order_params)
        redirect_to admin_order_path(@order), notice: 'Order updated successfully.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      order_id = @order.id
      @order.destroy
      redirect_to admin_orders_path, notice: 'Order deleted successfully.'
    end

    def cancel
      if @order.update(status: 'cancelled', cancellation_reason: params[:cancellation_reason])
        redirect_to admin_order_path(@order), notice: 'Order cancelled successfully.'
      else
        redirect_to admin_order_path(@order), alert: 'Failed to cancel order.'
      end
    end

    def update_status
      if @order.update(status: params[:status])
        redirect_to admin_order_path(@order), notice: 'Order status updated successfully.'
      else
        redirect_to admin_order_path(@order), alert: 'Failed to update order status.'
      end
    end

    def notes
      # Add note to order
      redirect_to admin_order_path(@order), notice: 'Note added successfully.'
    end

    def audit_log
      # Show audit log
    end

    def refund
      # Process refund
      redirect_to admin_order_path(@order), notice: 'Refund processed successfully.'
    end

    private

    def set_order
      @order = Order.find(params[:id])
    end

    def order_params
      params.require(:order).permit(:internal_notes, :tracking_number, :tracking_url)
    end

    def require_order_admin_role!
      unless current_admin&.super_admin? || current_admin&.order_admin?
        redirect_to admin_root_path, alert: 'You do not have permission to access this page.'
      end
    end
  end

