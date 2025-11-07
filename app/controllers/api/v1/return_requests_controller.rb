class Api::V1::ReturnRequestsController < ApplicationController
  # GET /api/v1/my-returns or /api/v1/return_requests
  def index
    @return_requests = current_user.return_requests.includes(
      order: [:order_items],
      return_items: [:order_item, :return_media]
    ).order(created_at: :desc)
    
    render_success(format_return_requests_data(@return_requests), 'Return requests retrieved successfully')
  end

  # GET /api/v1/return_requests/:id
  def show
    @return_request = current_user.return_requests.includes(
      order: [:order_items, :user],
      return_items: [:order_item, :return_media]
    ).find(params[:id])
    
    render_success(format_return_request_detail_data(@return_request), 'Return request retrieved successfully')
  rescue ActiveRecord::RecordNotFound
    render_not_found('Return request not found')
  end

  # POST /api/v1/return_requests
  def create
    @return_request = current_user.return_requests.build(return_request_params)
    @return_request.status = 'requested'
    
    if @return_request.save
      # Create return items
      if params[:items].present?
        params[:items].each do |item_params|
          return_item = @return_request.return_items.build(
            order_item_id: item_params[:order_item_id],
            quantity: item_params[:quantity],
            reason: item_params[:reason]
          )
          
          # Attach media if provided
          if item_params[:media].present?
            item_params[:media].each do |media_params|
              return_item.return_media.build(
                media_url: media_params[:file_key], # Assuming file_key is S3 key or URL
                media_type: media_params[:media_type] || 'image'
              )
            end
          end
          
          return_item.save!
        end
      end
      
      # Phase 3: Set return_id if not set
      @return_request.generate_return_id if @return_request.return_id.blank?
      @return_request.save!
      
      render_created(format_return_request_detail_data(@return_request.reload), 'Return request created successfully')
    else
      render_validation_errors(@return_request.errors.full_messages, 'Return request creation failed')
    end
  rescue ActiveRecord::RecordInvalid => e
    render_validation_errors(e.record.errors.full_messages, 'Return request creation failed')
  end

  # GET /api/v1/return_requests/:id/tracking
  def tracking
    @return_request = current_user.return_requests.find(params[:id])
    
    render_success({
      return_request: format_return_request_detail_data(@return_request),
      status_history: @return_request.status_history_data
    }, 'Return tracking retrieved successfully')
  rescue ActiveRecord::RecordNotFound
    render_not_found('Return request not found')
  end

  # POST /api/v1/return_requests/:id/pickup_schedule
  def pickup_schedule
    @return_request = current_user.return_requests.find(params[:id])
    
    pickup_params_data = params[:pickup] || {}
    scheduled_at = pickup_params_data[:scheduled_at]
    
    if scheduled_at.blank?
      render_validation_errors(['Pickup scheduled_at is required'], 'Pickup scheduling failed')
      return
    end
    
    if @return_request.update(
      pickup_scheduled_at: scheduled_at,
      status: 'pickup_scheduled'
    )
      # Update status history
      @return_request.update_status_history('pickup_scheduled', 'Pickup scheduled')
      
      render_success(format_return_request_detail_data(@return_request), 'Pickup scheduled successfully')
    else
      render_validation_errors(@return_request.errors.full_messages, 'Pickup scheduling failed')
    end
  rescue ActiveRecord::RecordNotFound
    render_not_found('Return request not found')
  end

  # PATCH /api/v1/admin/return_requests/:id/approve
  def admin_approve
    authorize_admin!
    
    @return_request = ReturnRequest.find(params[:id])
    
    if @return_request.update(
      status: 'approved',
      status_updated_at: Time.current
    )
      @return_request.update_status_history('approved', 'Return request approved by admin')
      
      render_success(format_return_request_detail_data(@return_request), 'Return request approved successfully')
    else
      render_validation_errors(@return_request.errors.full_messages, 'Approval failed')
    end
  rescue ActiveRecord::RecordNotFound
    render_not_found('Return request not found')
  end

  # PATCH /api/v1/admin/return_requests/:id/reject
  def admin_reject
    authorize_admin!
    
    @return_request = ReturnRequest.find(params[:id])
    rejection_reason = params[:rejection_reason] || 'Return request rejected'
    
    if @return_request.update(
      status: 'rejected',
      status_updated_at: Time.current
    )
      @return_request.update_status_history('rejected', rejection_reason)
      
      render_success(format_return_request_detail_data(@return_request), 'Return request rejected successfully')
    else
      render_validation_errors(@return_request.errors.full_messages, 'Rejection failed')
    end
  rescue ActiveRecord::RecordNotFound
    render_not_found('Return request not found')
  end

  # PATCH /api/v1/admin/return_requests/:id/process_refund
  def admin_process_refund
    authorize_admin!
    
    @return_request = ReturnRequest.find(params[:id])
    
    unless @return_request.status == 'approved' || @return_request.status == 'pickup_completed'
      render_error('Return request must be approved or pickup completed before processing refund', 'Invalid status')
      return
    end
    
    refund_params_data = params[:refund] || {}
    refund_amount = refund_params_data[:amount] || @return_request.refund_amount || @return_request.order.total_amount
    
    # Create payment refund if payment exists
    payment = @return_request.order.payments.where(status: ['completed', 'refunded']).first
    payment_refund = nil
    
    if payment
      payment_refund = payment.payment_refunds.create!(
        order: @return_request.order,
        amount: refund_amount,
        currency: payment.currency,
        reason: 'Return request refund',
        status: 'pending',
        processed_by: current_user
      )
    end
    
    if @return_request.update(
      refund_status: 'processing',
      refund_amount: refund_amount,
      refund_id: payment_refund&.refund_id,
      status: 'refund_processing'
    )
      @return_request.update_status_history('refund_processing', "Refund processing initiated for ₹#{refund_amount}")
      
      render_success(format_return_request_detail_data(@return_request), 'Refund processing initiated successfully')
    else
      render_validation_errors(@return_request.errors.full_messages, 'Refund processing failed')
    end
  rescue ActiveRecord::RecordNotFound
    render_not_found('Return request not found')
  end

  private

  def authorize_admin!
    render_unauthorized('Admin access required') unless current_user&.admin?
  end

  def return_request_params
    params.require(:return_request).permit(:order_id, :resolution_type)
  end

  def format_return_requests_data(return_requests)
    return_requests.map do |return_request|
      {
        id: return_request.id,
        order_id: return_request.order_id,
        status: return_request.status,
        resolution_type: return_request.resolution_type,
        created_at: return_request.created_at.iso8601,
        item_count: return_request.return_items.sum(:quantity)
      }
    end
  end

  def format_return_request_detail_data(return_request)
    {
      id: return_request.id,
      return_id: return_request.return_id,
      order_id: return_request.order_id,
      order_item_id: return_request.order_item_id,
      status: return_request.status,
      resolution_type: return_request.resolution_type,
      # Phase 3: Enhanced fields
      refund_status: return_request.refund_status || nil,
      refund_amount: return_request.refund_amount&.to_f,
      refund_id: return_request.refund_id,
      pickup_scheduled_at: return_request.pickup_scheduled_at,
      pickup_completed_at: return_request.pickup_completed_at,
      return_quantity: return_request.return_quantity,
      return_condition: return_request.return_condition,
      return_images: return_request.return_images_list,
      status_updated_at: return_request.status_updated_at,
      created_at: return_request.created_at.iso8601,
      order: {
        id: return_request.order.id,
        order_number: return_request.order.order_number || return_request.order.id.to_s.rjust(8, '0'),
        total_amount: return_request.order.total_amount
      },
      items: return_request.return_items.map do |item|
        {
          id: item.id,
          order_item: {
            id: item.order_item.id,
            product_name: item.order_item.product_name || item.order_item.product_variant.product.name,
            sku: item.order_item.product_variant.sku,
            quantity: item.order_item.quantity
          },
          quantity: item.quantity,
          reason: item.reason,
          media: item.return_media.map do |media|
            {
              id: media.id,
              url: media.media_url,
              type: media.media_type
            }
          end
        }
      end
    }
  end
end
