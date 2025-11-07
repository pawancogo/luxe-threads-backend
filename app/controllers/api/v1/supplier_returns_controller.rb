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
    
    render_success(format_return_requests_data(@return_requests), 'Supplier return requests retrieved successfully')
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
    
    render_success(format_return_request_detail_data(@return_request), 'Return request retrieved successfully')
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
    
    # Only allow approval if status is requested
    unless @return_request.status == 'requested'
      render_validation_errors(['Return request can only be approved when status is requested'], 'Invalid return status')
      return
    end
    
    notes = params[:notes] || params.dig(:return_request, :notes)
    
    if @return_request.update(status: 'approved', status_updated_at: Time.current)
      @return_request.add_status_to_history('approved', "Approved by supplier: #{notes || 'No notes provided'}")
      
      # Update order items to mark as return requested
      @return_request.return_items.each do |return_item|
        return_item.order_item.update!(return_requested: true)
      end
      
      render_success(format_return_request_detail_data(@return_request.reload), 'Return request approved successfully')
    else
      render_validation_errors(@return_request.errors.full_messages, 'Failed to approve return request')
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
    
    # Only allow rejection if status is requested
    unless @return_request.status == 'requested'
      render_validation_errors(['Return request can only be rejected when status is requested'], 'Invalid return status')
      return
    end
    
    rejection_reason = params[:rejection_reason] || params.dig(:return_request, :rejection_reason)
    
    unless rejection_reason.present?
      render_validation_errors(['Rejection reason is required'], 'Rejection reason required')
      return
    end
    
    if @return_request.update(status: 'rejected', status_updated_at: Time.current)
      @return_request.add_status_to_history('rejected', "Rejected by supplier: #{rejection_reason}")
      
      render_success(format_return_request_detail_data(@return_request.reload), 'Return request rejected successfully')
    else
      render_validation_errors(@return_request.errors.full_messages, 'Failed to reject return request')
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
      return_request: format_return_request_detail_data(@return_request),
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

  def format_return_requests_data(return_requests)
    return_requests.map { |rr| format_return_request_data(rr) }
  end

  def format_return_request_data(return_request)
    {
      id: return_request.id,
      return_id: return_request.return_id,
      order_id: return_request.order_id,
      order_number: return_request.order.order_number || return_request.order.id.to_s.rjust(8, '0'),
      customer_name: return_request.user.full_name,
      customer_email: return_request.user.email,
      status: return_request.status,
      resolution_type: return_request.resolution_type,
      refund_status: return_request.refund_status,
      created_at: return_request.created_at.iso8601,
      status_updated_at: return_request.status_updated_at&.iso8601,
      items_count: return_request.return_items.count,
      total_quantity: return_request.return_items.sum(:quantity)
    }
  end

  def format_return_request_detail_data(return_request)
    format_return_request_data(return_request).merge(
      items: return_request.return_items.map do |return_item|
        order_item = return_item.order_item
        variant = order_item.product_variant
        product = variant.product
        
        {
          return_item_id: return_item.id,
          order_item_id: order_item.id,
          product_name: order_item.product_name || product.name,
          product_variant_id: variant.id,
          sku: variant.sku,
          quantity: return_item.quantity,
          reason: return_item.reason,
          price_at_purchase: order_item.price_at_purchase,
          subtotal: order_item.price_at_purchase * return_item.quantity,
          image_url: order_item.product_image_url || variant.product_images.first&.image_url || product.product_variants.first&.product_images&.first&.image_url
        }
      end,
      order: {
        id: return_request.order.id,
        order_number: return_request.order.order_number || return_request.order.id.to_s.rjust(8, '0'),
        total_amount: return_request.order.total_amount,
        currency: return_request.order.currency || 'INR',
        order_date: return_request.order.created_at.iso8601
      },
      status_history: return_request.status_history_data,
      pickup_address: return_request.pickup_address ? format_address_data(return_request.pickup_address) : nil,
      pickup_scheduled_at: return_request.pickup_scheduled_at&.iso8601,
      refund_amount: return_request.refund_amount,
      refund_id: return_request.refund_id
    )
  end
end

