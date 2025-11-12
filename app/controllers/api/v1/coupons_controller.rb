# frozen_string_literal: true

class Api::V1::CouponsController < ApplicationController
  include ServiceResponseHandler
  
  skip_before_action :authenticate_request, only: [:validate]

  # GET /api/v1/coupons/validate?code=COUPON123
  def validate
    service = Coupons::ValidationService.new(
      params[:code],
      user: current_user
    )
    service.call
    
    if service.success?
      render_success(
        CouponSerializer.new(service.coupon).as_json,
        'Coupon is valid'
      )
    else
      handle_service_errors(service, 'Validation failed')
    end
  end

  # POST /api/v1/coupons/apply
  def apply
    service = Coupons::ApplicationService.new(
      params[:code],
      params[:order_amount],
      current_user
    )
    service.call
    
    if service.success?
      render_success({
        coupon: CouponSerializer.new(service.coupon).as_json,
        discount_amount: service.discount_amount.to_f,
        final_amount: service.final_amount.to_f
      }, 'Coupon applied successfully')
    else
      handle_service_errors(service, 'Application failed')
    end
  end

  # GET /api/v1/admin/coupons
  def admin_index
    authorize_admin!
    
    service = Admins::CouponListingService.new(params)
    service.call
    
    if service.success?
      serialized_coupons = CouponSerializer.collection(service.coupons)
      render_success(serialized_coupons, 'Coupons retrieved successfully')
    else
      handle_service_errors(service, 'Failed to retrieve coupons')
    end
  end

  # POST /api/v1/admin/coupons
  def admin_create
    authorize_admin!
    
    coupon_params_data = params[:coupon] || {}
    
    service = Coupons::CreationService.new(coupon_params_data)
    service.call
    
    if service.success?
      render_created(
        CouponSerializer.new(service.coupon).detailed,
        'Coupon created successfully'
      )
    else
      handle_service_errors(service, 'Coupon creation failed')
    end
  end

  # PATCH /api/v1/admin/coupons/:id
  def admin_update
    authorize_admin!
    
    @coupon = Coupon.find(params[:id])
    coupon_params_data = params[:coupon] || {}
    
    service = Coupons::UpdateService.new(@coupon, coupon_params_data)
    service.call
    
    if service.success?
      render_success(
        CouponSerializer.new(@coupon.reload).detailed,
        'Coupon updated successfully'
      )
    else
      handle_service_errors(service, 'Coupon update failed')
    end
  rescue ActiveRecord::RecordNotFound
    render_not_found('Coupon not found')
  end

  # DELETE /api/v1/admin/coupons/:id
  def admin_destroy
    authorize_admin!
    
    @coupon = Coupon.find(params[:id])
    
    if @coupon.destroy
      render_success({ id: @coupon.id }, 'Coupon deleted successfully')
    else
      render_validation_errors(@coupon.errors.full_messages, 'Coupon deletion failed')
    end
  rescue ActiveRecord::RecordNotFound
    render_not_found('Coupon not found')
  end

  private

  def authorize_admin!
    render_unauthorized('Admin access required') unless current_user&.admin?
  end
end


