# frozen_string_literal: true

# Refactored ReturnRequestsController using Clean Architecture
# Controller → Service → Model → Serializer
class Api::V1::ReturnRequestsController < ApplicationController
  before_action :set_return_request, only: [:show, :tracking, :pickup_schedule]

  # GET /api/v1/my-returns or /api/v1/return_requests
  def index
    return_requests = ReturnRequest.for_customer(current_user).recent
    
    serialized_returns = return_requests.map { |rr| ReturnRequestSerializer.new(rr).as_json }
    render_success(serialized_returns, 'Return requests retrieved successfully')
  end

  # GET /api/v1/return_requests/:id
  def show
    return_request = ReturnRequest.with_full_details.find(@return_request.id)
    
    render_success(
      ReturnRequestSerializer.new(return_request).detailed,
      'Return request retrieved successfully'
    )
  rescue ActiveRecord::RecordNotFound
    render_not_found('Return request not found')
  end

  # POST /api/v1/return_requests
  def create
    order = current_user.orders.find(return_request_params[:order_id])
    
      service = Returns::RequestCreationService.new(
      current_user,
      order,
      return_request_params,
      params[:items]
    )
    service.call
    
    if service.success?
      render_created(
        ReturnRequestSerializer.new(service.return_request).detailed,
        'Return request created successfully'
      )
    else
      render_validation_errors(service.errors, 'Return request creation failed')
    end
  rescue ActiveRecord::RecordNotFound
    render_not_found('Order not found')
  end

  # GET /api/v1/return_requests/:id/tracking
  def tracking
    return_request = ReturnRequest.with_full_details.find(@return_request.id)
    
    render_success({
      return_request: ReturnRequestSerializer.new(return_request).detailed,
      status_history: return_request.status_history_data || []
    }, 'Return tracking retrieved successfully')
  rescue ActiveRecord::RecordNotFound
    render_not_found('Return request not found')
  end

  # POST /api/v1/return_requests/:id/pickup_schedule
  def pickup_schedule
    scheduled_at = params.dig(:pickup, :scheduled_at)
    
    service = ReturnPickupSchedulingService.new(@return_request, scheduled_at)
    service.call
    
    if service.success?
      render_success(
        ReturnRequestSerializer.new(service.return_request).detailed,
        'Pickup scheduled successfully'
      )
    else
      render_validation_errors(service.errors, 'Pickup scheduling failed')
    end
  rescue ActiveRecord::RecordNotFound
    render_not_found('Return request not found')
  end

  # PATCH /api/v1/admin/return_requests/:id/approve
  def admin_approve
    authorize_admin!
    
    return_request = ReturnRequest.find(params[:id])
    service = Returns::ApprovalService.new(return_request, current_user)
    service.call
    
    if service.success?
      render_success(
        ReturnRequestSerializer.new(service.return_request).detailed,
        'Return request approved successfully'
      )
    else
      render_validation_errors(service.errors, 'Approval failed')
    end
  rescue ActiveRecord::RecordNotFound
    render_not_found('Return request not found')
  end

  # PATCH /api/v1/admin/return_requests/:id/reject
  def admin_reject
    authorize_admin!
    
    return_request = ReturnRequest.find(params[:id])
    service = Returns::RejectionService.new(
      return_request,
      params[:rejection_reason],
      current_user
    )
    service.call
    
    if service.success?
      render_success(
        ReturnRequestSerializer.new(service.return_request).detailed,
        'Return request rejected successfully'
      )
    else
      render_validation_errors(service.errors, 'Rejection failed')
    end
  rescue ActiveRecord::RecordNotFound
    render_not_found('Return request not found')
  end

  # PATCH /api/v1/admin/return_requests/:id/process_refund
  def admin_process_refund
    authorize_admin!
    
    return_request = ReturnRequest.find(params[:id])
    refund_amount = params.dig(:refund, :amount)
    
    service = ReturnRefundProcessingService.new(return_request, refund_amount, current_user)
    service.call
    
    if service.success?
      render_success(
        ReturnRequestSerializer.new(service.return_request).detailed,
        'Refund processing initiated successfully'
      )
    else
      render_validation_errors(service.errors, 'Refund processing failed')
    end
  rescue ActiveRecord::RecordNotFound
    render_not_found('Return request not found')
  end

  private

  def set_return_request
    @return_request = current_user.return_requests.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found('Return request not found')
  end

  def authorize_admin!
    render_unauthorized('Admin access required') unless current_user&.admin?
  end

  def return_request_params
    params.require(:return_request).permit(:order_id, :resolution_type)
  end
end
