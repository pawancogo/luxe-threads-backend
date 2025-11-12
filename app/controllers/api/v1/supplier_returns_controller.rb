# frozen_string_literal: true

class Api::V1::SupplierReturnsController < ApplicationController
  include ApiFormatters
  
  before_action :authorize_supplier!
  before_action :ensure_supplier_profile!

  # GET /api/v1/supplier/returns
  def index
    supplier_profile = current_user.supplier_profile
    
    # Get return requests for order items belonging to this supplier
    # Join through return_items -> order_items -> supplier_profile
    @return_requests = ReturnRequest.joins(
      return_items: :order_item
    ).where(
      order_items: { supplier_profile_id: supplier_profile.id }
    ).includes(
      :user, :order, :return_items => [:order_item => [:product_variant => [:product => [:brand, :category]]]]
    ).order(created_at: :desc)
    
    # Filter by status if provided
    @return_requests = @return_requests.where(status: params[:status]) if params[:status].present?
    
    render_success(
      SupplierReturnRequestSerializer.collection(@return_requests),
      'Supplier return requests retrieved successfully'
    )
  end

  # GET /api/v1/supplier/returns/:id
  def show
    supplier_profile = current_user.supplier_profile
    
    @return_request = ReturnRequest.joins(
      return_items: :order_item
    ).where(
      order_items: { supplier_profile_id: supplier_profile.id }
    ).includes(
      :user, :order, :return_items => [:order_item => [:product_variant => [:product => [:brand, :category]]]]
    ).find(params[:id])
    
    render_success(
      SupplierReturnRequestSerializer.new(@return_request).as_json,
      'Return request retrieved successfully'
    )
  rescue ActiveRecord::RecordNotFound
    render_not_found('Return request not found')
  end

  # POST /api/v1/supplier/returns/:id/approve
  def approve
    supplier_profile = current_user.supplier_profile
    
    @return_request = ReturnRequest.joins(
      return_items: :order_item
    ).where(
      order_items: { supplier_profile_id: supplier_profile.id }
    ).find(params[:id])
    
    notes = params[:notes] || params.dig(:return_request, :notes)
    service = Suppliers::ReturnApprovalService.new(@return_request, supplier_profile, notes: notes)
    service.call
    
    if service.success?
      render_success(
        SupplierReturnRequestSerializer.new(@return_request.reload).as_json,
        'Return request approved successfully'
      )
    else
      render_validation_errors(service.errors, 'Failed to approve return request')
    end
  rescue ActiveRecord::RecordNotFound
    render_not_found('Return request not found')
  rescue StandardError => e
    Rails.logger.error "Error approving return request: #{e.message}"
    render_error('Failed to approve return request', 'Internal server error')
  end

  # POST /api/v1/supplier/returns/:id/reject
  def reject
    supplier_profile = current_user.supplier_profile
    
    @return_request = ReturnRequest.joins(
      return_items: :order_item
    ).where(
      order_items: { supplier_profile_id: supplier_profile.id }
    ).find(params[:id])
    
    rejection_reason = params[:rejection_reason] || params.dig(:return_request, :rejection_reason)
    service = Suppliers::ReturnRejectionService.new(@return_request, supplier_profile, rejection_reason)
    service.call
    
    if service.success?
      render_success(
        SupplierReturnRequestSerializer.new(@return_request.reload).as_json,
        'Return request rejected successfully'
      )
    else
      render_validation_errors(service.errors, 'Failed to reject return request')
    end
  rescue ActiveRecord::RecordNotFound
    render_not_found('Return request not found')
  rescue StandardError => e
    Rails.logger.error "Error rejecting return request: #{e.message}"
    render_error('Failed to reject return request', 'Internal server error')
  end

  # GET /api/v1/supplier/returns/:id/tracking
  def tracking
    supplier_profile = current_user.supplier_profile
    
    @return_request = ReturnRequest.joins(
      return_items: :order_item
    ).where(
      order_items: { supplier_profile_id: supplier_profile.id }
    ).find(params[:id])
    
    render_success({
      return_request: SupplierReturnRequestSerializer.new(@return_request).as_json,
      status_history: @return_request.status_history_data
    }, 'Return tracking retrieved successfully')
  rescue ActiveRecord::RecordNotFound
    render_not_found('Return request not found')
  end

  private

  def authorize_supplier!
    render_unauthorized('Not Authorized') unless current_user.supplier?
  end

  def ensure_supplier_profile!
    if current_user.supplier_profile.nil?
      render_validation_errors(
        ['Supplier profile not found. Please create a supplier profile first.'],
        'Supplier profile required'
      )
      return
    end
  end

end

