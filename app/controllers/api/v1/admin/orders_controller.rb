# frozen_string_literal: true

module Api::V1::Admin
  class OrdersController < BaseController
    include AdminApiAuthorization
    include EagerLoading
    
    before_action :require_order_admin_role!, only: [:index, :show, :update, :destroy, :cancel, :update_status, :add_note, :audit_log, :refund]
    before_action :set_order, only: [:show, :update, :destroy, :cancel, :update_status, :add_note, :audit_log, :refund]
    
    # GET /api/v1/admin/orders
    def index
      base_scope = with_eager_loading(
        Order.all,
        additional_includes: order_includes
      )
      
      service = Admins::OrderListingService.new(base_scope, params)
      service.call
      
      if service.success?
        render_success(
          AdminOrderSerializer.collection(service.orders),
          'Orders retrieved successfully'
        )
      else
        render_validation_errors(service.errors, 'Failed to retrieve orders')
      end
    end
    
    # GET /api/v1/admin/orders/:id
    def show
      render_success(
        AdminOrderSerializer.new(@order).as_json,
        'Order retrieved successfully'
      )
    end
    
    # PATCH /api/v1/admin/orders/:id
    def update
      service = Orders::GeneralUpdateService.new(@order, order_update_params)
      service.call
      
      if service.success?
        log_admin_activity('update', 'Order', @order.id, @order.previous_changes)
        render_success(
          AdminOrderSerializer.new(@order.reload).as_json,
          'Order updated successfully'
        )
      else
        render_validation_errors(service.errors, 'Order update failed')
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
      
      service = Orders::CancellationService.new(
        @order,
        cancellation_reason,
        cancelled_by: "admin_#{@current_admin.id}"
      )
      service.call
      
      if service.success?
        log_admin_activity('cancel', 'Order', @order.id, { 
          status: [@order.status_before_last_save, 'cancelled'],
          cancellation_reason: cancellation_reason
        })
        render_success(
          AdminOrderSerializer.new(@order.reload).as_json,
          'Order cancelled successfully'
        )
      else
        render_validation_errors(service.errors, 'Failed to cancel order')
      end
    end
    
    # PATCH /api/v1/admin/orders/:id/update_status
    def update_status
      new_status = params[:status] || params.dig(:order, :status)
      
      service = Orders::StatusUpdateService.new(
        @order,
        new_status,
        updated_by: "admin_#{@current_admin.id}"
      )
      service.call
      
      if service.success?
        old_status = @order.status_before_last_save
        log_admin_activity('update_status', 'Order', @order.id, { 
          status: [old_status, new_status],
          updated_by: "admin_#{@current_admin.id}"
        })
        render_success(
          AdminOrderSerializer.new(@order.reload).as_json,
          'Order status updated successfully'
        )
      else
        render_validation_errors(service.errors, 'Order status update failed')
      end
    end
    
    # POST /api/v1/admin/orders/:id/notes
    def add_note
      note = params[:note] || params.dig(:order, :note)
      
      service = Orders::NoteAdditionService.new(@order, note, @current_admin)
      service.call
      
      if service.success?
        log_admin_activity('add_note', 'Order', @order.id, { note: note })
        render_success(
          AdminOrderSerializer.new(@order.reload).as_json,
          'Note added successfully'
        )
      else
        render_validation_errors(service.errors, 'Failed to add note')
      end
    end
    
    # GET /api/v1/admin/orders/:id/audit_log
    def audit_log
      service = Orders::AuditLogService.new(@order)
      service.call
      
      if service.success?
        render_success(service.audit_entries, 'Audit log retrieved successfully')
      else
        render_error(service.errors.first || 'Failed to retrieve audit log', :unprocessable_entity)
      end
    end
    
    # PATCH /api/v1/admin/orders/:id/refund
    def refund
      refund_amount = params[:refund_amount] || params.dig(:refund, :amount)
      refund_reason = params[:refund_reason] || params.dig(:refund, :reason) || 'Admin refund'
      
      service = Orders::RefundService.new(
        @order,
        refund_amount,
        refund_reason: refund_reason,
        admin: @current_admin
      )
      service.call
      
      if service.success?
        log_admin_activity('refund', 'Order', @order.id, { 
          refund_amount: refund_amount,
          refund_reason: refund_reason,
          payment_refund_id: service.payment_refund.id
        })
        render_success(
          AdminOrderSerializer.new(@order.reload).as_json,
          'Refund processed successfully'
        )
      else
        render_validation_errors(service.errors, 'Failed to process refund')
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
    
    def order_update_params
      (params[:order] || {}).permit(:internal_notes, :tracking_number, :tracking_url).compact
    end
    
  end
end

