# frozen_string_literal: true

module Api::V1::Admin
  class OrdersController < BaseController
    include AdminApiAuthorization
    include EagerLoading
    
    before_action :require_order_admin_role!, only: [:index, :show, :update, :destroy, :cancel, :update_status, :add_note, :audit_log, :refund]
    before_action :set_order, only: [:show, :update, :destroy, :cancel, :update_status, :add_note, :audit_log, :refund]
    
    # GET /api/v1/admin/orders
    def index
      @orders = with_eager_loading(
        Order.all,
        additional_includes: order_includes
      ).order(created_at: :desc)
      
      # Filters
      @orders = @orders.where(status: params[:status]) if params[:status].present?
      @orders = @orders.where(payment_status: params[:payment_status]) if params[:payment_status].present?
      @orders = @orders.where(user_id: params[:user_id]) if params[:user_id].present?
      @orders = @orders.where('order_number LIKE ?', "%#{params[:order_number]}%") if params[:order_number].present?
      
      # Date range filter
      if params[:created_from].present?
        @orders = @orders.where('created_at >= ?', params[:created_from])
      end
      if params[:created_to].present?
        @orders = @orders.where('created_at <= ?', params[:created_to])
      end
      
      # Amount range filter
      if params[:min_amount].present?
        @orders = @orders.where('total_amount >= ?', params[:min_amount])
      end
      if params[:max_amount].present?
        @orders = @orders.where('total_amount <= ?', params[:max_amount])
      end
      
      # Pagination
      page = params[:page]&.to_i || 1
      per_page = params[:per_page]&.to_i || 20
      @orders = @orders.page(page).per(per_page)
      
      render_success(format_orders_data(@orders), 'Orders retrieved successfully')
    end
    
    # GET /api/v1/admin/orders/:id
    def show
      render_success(format_order_detail_data(@order), 'Order retrieved successfully')
    end
    
    # PATCH /api/v1/admin/orders/:id
    def update
      order_params_data = params[:order] || {}
      
      update_hash = {}
      update_hash[:internal_notes] = order_params_data[:internal_notes] if order_params_data.key?(:internal_notes)
      update_hash[:tracking_number] = order_params_data[:tracking_number] if order_params_data.key?(:tracking_number)
      update_hash[:tracking_url] = order_params_data[:tracking_url] if order_params_data.key?(:tracking_url)
      
      if @order.update(update_hash)
        log_admin_activity('update', 'Order', @order.id, @order.previous_changes)
        render_success(format_order_detail_data(@order), 'Order updated successfully')
      else
        render_validation_errors(@order.errors.full_messages, 'Order update failed')
      end
    end
    
    # DELETE /api/v1/admin/orders/:id
    def destroy
      order_id = @order.id
      order_number = @order.order_number
      if @order.destroy
        log_admin_activity('destroy', 'Order', order_id)
        render_success({ id: order_id, order_number: order_number }, 'Order deleted successfully')
      else
        render_validation_errors(@order.errors.full_messages, 'Order deletion failed')
      end
    end
    
    # PATCH /api/v1/admin/orders/:id/cancel
    def cancel
      cancellation_reason = params[:cancellation_reason] || params.dig(:order, :cancellation_reason)
      
      unless cancellation_reason.present?
        render_validation_errors(['Cancellation reason is required'], 'Cancellation reason must be provided')
        return
      end
      
      unless @order.can_be_cancelled?
        render_validation_errors(['Order cannot be cancelled'], 'Order has already been shipped or delivered')
        return
      end
      
      begin
        @order.cancel!(cancellation_reason, "admin_#{@current_admin.id}")
        log_admin_activity('cancel', 'Order', @order.id, { 
          status: [@order.status_before_last_save, 'cancelled'],
          cancellation_reason: cancellation_reason
        })
        render_success(format_order_detail_data(@order), 'Order cancelled successfully')
      rescue StandardError => e
        render_error(e.message, 'Failed to cancel order')
      end
    end
    
    # PATCH /api/v1/admin/orders/:id/update_status
    def update_status
      new_status = params[:status] || params.dig(:order, :status)
      
      unless new_status.present?
        render_validation_errors(['Status is required'], 'Status must be provided')
        return
      end
      
      unless Order.statuses.key?(new_status)
        render_validation_errors(['Invalid status'], "Status must be one of: #{Order.statuses.keys.join(', ')}")
        return
      end
      
      old_status = @order.status
      if @order.update(status: new_status)
        log_admin_activity('update_status', 'Order', @order.id, { 
          status: [old_status, new_status],
          updated_by: "admin_#{@current_admin.id}"
        })
        render_success(format_order_detail_data(@order), 'Order status updated successfully')
      else
        render_validation_errors(@order.errors.full_messages, 'Order status update failed')
      end
    end
    
    # POST /api/v1/admin/orders/:id/notes
    def add_note
      note = params[:note] || params.dig(:order, :note)
      
      unless note.present?
        render_validation_errors(['Note is required'], 'Note must be provided')
        return
      end
      
      # Append to internal_notes with timestamp and admin info
      timestamp = Time.current.strftime('%Y-%m-%d %H:%M:%S')
      admin_name = @current_admin.full_name
      new_note = "\n[#{timestamp}] #{admin_name}: #{note}"
      
      current_notes = @order.internal_notes || ''
      if @order.update(internal_notes: current_notes + new_note)
        log_admin_activity('add_note', 'Order', @order.id, { note: note })
        render_success(format_order_detail_data(@order), 'Note added successfully')
      else
        render_validation_errors(@order.errors.full_messages, 'Failed to add note')
      end
    end
    
    # GET /api/v1/admin/orders/:id/audit_log
    def audit_log
      # Get PaperTrail versions
      versions = @order.versions.order(created_at: :desc)
      
      # Get status history from JSON field
      status_history = @order.status_history_array
      
      # Combine audit trail
      audit_entries = []
      
      # Add PaperTrail versions
      versions.each do |version|
        audit_entries << {
          type: 'version',
          event: version.event,
          timestamp: version.created_at,
          whodunnit: version.whodunnit,
          changes: version.changeset,
          admin_id: version.whodunnit&.match(/admin_(\d+)/)&.captures&.first
        }
      end
      
      # Add status history entries
      status_history.each do |entry|
        audit_entries << {
          type: 'status_change',
          status: entry['status'],
          timestamp: entry['timestamp'],
          note: entry['note']
        }
      end
      
      # Sort by timestamp
      audit_entries.sort_by! { |e| e[:timestamp] || Time.current }.reverse!
      
      render_success(audit_entries, 'Audit log retrieved successfully')
    end
    
    # PATCH /api/v1/admin/orders/:id/refund
    def refund
      refund_amount = params[:refund_amount] || params.dig(:refund, :amount)
      refund_reason = params[:refund_reason] || params.dig(:refund, :reason) || 'Admin refund'
      
      unless refund_amount.present?
        render_validation_errors(['Refund amount is required'], 'Refund amount must be provided')
        return
      end
      
      refund_amount = refund_amount.to_f
      
      if refund_amount <= 0 || refund_amount > @order.total_amount
        render_validation_errors(['Invalid refund amount'], 'Refund amount must be greater than 0 and not exceed order total')
        return
      end
      
      # Find payment to refund
      payment = @order.payments.where(status: ['completed', 'refunded']).first
      
      unless payment
        render_error('No payment found for this order', 'Cannot process refund without payment')
        return
      end
      
      begin
        # Create payment refund
        payment_refund = payment.payment_refunds.create!(
          order: @order,
          amount: refund_amount,
          currency: payment.currency || 'INR',
          reason: refund_reason,
          status: 'pending',
          processed_by: nil # Admin refund - will be processed by payment gateway
        )
        
        # Update payment status
        if refund_amount >= payment.amount
          payment.update(status: 'refunded')
        else
          payment.update(status: 'partially_refunded')
        end
        
        log_admin_activity('refund', 'Order', @order.id, { 
          refund_amount: refund_amount,
          refund_reason: refund_reason,
          payment_refund_id: payment_refund.id
        })
        
        render_success(format_order_detail_data(@order), 'Refund processed successfully')
      rescue StandardError => e
        Rails.logger.error "Refund error: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render_error(e.message, 'Failed to process refund')
      end
    end
    
    private
    
    def require_order_admin_role!
      require_role!(['super_admin', 'order_admin'])
    end
    
    def set_order
      @order = with_eager_loading(Order.all, additional_includes: order_includes).find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_not_found('Order not found')
    end
    
    def format_orders_data(orders)
      orders.map { |order| format_order_data(order) }
    end
    
    def format_order_data(order)
      {
        id: order.id,
        order_number: order.order_number,
        status: order.status,
        payment_status: order.payment_status,
        total_amount: order.total_amount.to_f,
        currency: order.currency || 'INR',
        user: {
          id: order.user.id,
          name: order.user.full_name,
          email: order.user.email
        },
        items_count: order.order_items.count,
        created_at: order.created_at,
        updated_at: order.updated_at
      }
    end
    
    def format_order_detail_data(order)
      format_order_data(order).merge(
        shipping_address: format_address(order.shipping_address),
        billing_address: format_address(order.billing_address),
        items: order.order_items.map do |item|
          {
            id: item.id,
            product_name: item.product_name || item.product_variant&.product&.name,
            variant_sku: item.variant_sku || item.product_variant&.sku,
            quantity: item.quantity,
            price: item.price.to_f,
            total: (item.price * item.quantity).to_f
          }
        end,
        payments: order.payments.map do |payment|
          {
            id: payment.id,
            amount: payment.amount.to_f,
            status: payment.status,
            method: payment.payment_method,
            created_at: payment.created_at
          }
        end,
        refunds: order.payment_refunds.map do |refund|
          {
            id: refund.id,
            amount: refund.amount.to_f,
            status: refund.status,
            reason: refund.reason,
            created_at: refund.created_at
          }
        end,
        status_history: order.status_history_array,
        internal_notes: order.internal_notes,
        customer_notes: order.customer_notes,
        tracking_number: order.tracking_number,
        tracking_url: order.tracking_url,
        cancellation_reason: order.cancellation_reason,
        cancelled_at: order.cancelled_at,
        cancelled_by: order.cancelled_by
      )
    end
    
    def format_address(address)
      return nil unless address
      {
        id: address.id,
        street: address.street,
        city: address.city,
        state: address.state,
        zip_code: address.zip_code,
        country: address.country,
        phone_number: address.phone_number
      }
    end
  end
end

