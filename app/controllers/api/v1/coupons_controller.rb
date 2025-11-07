# frozen_string_literal: true

class Api::V1::CouponsController < ApplicationController
  skip_before_action :authenticate_request, only: [:validate]

  # GET /api/v1/coupons/validate?code=COUPON123
  def validate
    code = params[:code]
    
    if code.blank?
      render_validation_errors(['Coupon code is required'], 'Validation failed')
      return
    end
    
    @coupon = Coupon.find_by(code: code.upcase)
    
    if @coupon.nil?
      render_error('Coupon not found', 'Invalid coupon code')
      return
    end
    
    unless @coupon.available?
      render_error('Coupon is not available', 'Coupon expired or inactive')
      return
    end
    
    # Check if user is authenticated (for user-specific validation)
    if current_user.present?
      unless @coupon.valid_for_user?(current_user)
        render_error('Coupon not valid for this user', 'User restrictions apply')
        return
      end
    end
    
    render_success(format_coupon_data(@coupon), 'Coupon is valid')
  end

  # POST /api/v1/coupons/apply
  def apply
    code = params[:code]
    order_amount = params[:order_amount]&.to_f || 0
    
    if code.blank?
      render_validation_errors(['Coupon code is required'], 'Application failed')
      return
    end
    
    @coupon = Coupon.find_by(code: code.upcase)
    
    if @coupon.nil?
      render_error('Coupon not found', 'Invalid coupon code')
      return
    end
    
    unless @coupon.available?
      render_error('Coupon is not available', 'Coupon expired or inactive')
      return
    end
    
    unless @coupon.valid_for_user?(current_user)
      render_error('Coupon not valid for this user', 'User restrictions apply')
      return
    end
    
    if order_amount < @coupon.min_order_amount
      render_error("Minimum order amount is ₹#{@coupon.min_order_amount}", 'Minimum order amount not met')
      return
    end
    
    discount_amount = @coupon.calculate_discount(order_amount)
    
    render_success({
      coupon: format_coupon_data(@coupon),
      discount_amount: discount_amount.to_f,
      final_amount: (order_amount - discount_amount).to_f
    }, 'Coupon applied successfully')
  end

  # GET /api/v1/admin/coupons
  def admin_index
    authorize_admin!
    
    @coupons = Coupon.order(created_at: :desc)
    
    # Filter by active status if provided
    @coupons = @coupons.where(is_active: params[:is_active] == 'true') if params[:is_active].present?
    
    # Filter by coupon_type if provided
    @coupons = @coupons.where(coupon_type: params[:coupon_type]) if params[:coupon_type].present?
    
    render_success(format_coupons_data(@coupons), 'Coupons retrieved successfully')
  end

  # POST /api/v1/admin/coupons
  def admin_create
    authorize_admin!
    
    coupon_params_data = params[:coupon] || {}
    
    @coupon = Coupon.new(
      code: coupon_params_data[:code]&.upcase,
      name: coupon_params_data[:name],
      description: coupon_params_data[:description],
      coupon_type: coupon_params_data[:coupon_type],
      discount_value: coupon_params_data[:discount_value],
      max_discount_amount: coupon_params_data[:max_discount_amount],
      min_order_amount: coupon_params_data[:min_order_amount] || 0,
      valid_from: coupon_params_data[:valid_from],
      valid_until: coupon_params_data[:valid_until],
      is_active: coupon_params_data[:is_active] != false,
      max_uses: coupon_params_data[:max_uses],
      max_uses_per_user: coupon_params_data[:max_uses_per_user],
      is_new_user_only: coupon_params_data[:is_new_user_only] || false,
      is_first_order_only: coupon_params_data[:is_first_order_only] || false,
      applicable_categories: coupon_params_data[:applicable_categories]&.to_json,
      applicable_products: coupon_params_data[:applicable_products]&.to_json,
      applicable_brands: coupon_params_data[:applicable_brands]&.to_json,
      applicable_suppliers: coupon_params_data[:applicable_suppliers]&.to_json
    )
    
    if @coupon.save
      render_created(format_coupon_detail_data(@coupon), 'Coupon created successfully')
    else
      render_validation_errors(@coupon.errors.full_messages, 'Coupon creation failed')
    end
  end

  # PATCH /api/v1/admin/coupons/:id
  def admin_update
    authorize_admin!
    
    @coupon = Coupon.find(params[:id])
    coupon_params_data = params[:coupon] || {}
    
    update_hash = {}
    update_hash[:code] = coupon_params_data[:code]&.upcase if coupon_params_data.key?(:code)
    update_hash[:name] = coupon_params_data[:name] if coupon_params_data.key?(:name)
    update_hash[:description] = coupon_params_data[:description] if coupon_params_data.key?(:description)
    update_hash[:coupon_type] = coupon_params_data[:coupon_type] if coupon_params_data.key?(:coupon_type)
    update_hash[:discount_value] = coupon_params_data[:discount_value] if coupon_params_data.key?(:discount_value)
    update_hash[:max_discount_amount] = coupon_params_data[:max_discount_amount] if coupon_params_data.key?(:max_discount_amount)
    update_hash[:min_order_amount] = coupon_params_data[:min_order_amount] if coupon_params_data.key?(:min_order_amount)
    update_hash[:valid_from] = coupon_params_data[:valid_from] if coupon_params_data.key?(:valid_from)
    update_hash[:valid_until] = coupon_params_data[:valid_until] if coupon_params_data.key?(:valid_until)
    update_hash[:is_active] = coupon_params_data[:is_active] if coupon_params_data.key?(:is_active)
    update_hash[:max_uses] = coupon_params_data[:max_uses] if coupon_params_data.key?(:max_uses)
    update_hash[:max_uses_per_user] = coupon_params_data[:max_uses_per_user] if coupon_params_data.key?(:max_uses_per_user)
    update_hash[:is_new_user_only] = coupon_params_data[:is_new_user_only] if coupon_params_data.key?(:is_new_user_only)
    update_hash[:is_first_order_only] = coupon_params_data[:is_first_order_only] if coupon_params_data.key?(:is_first_order_only)
    update_hash[:applicable_categories] = coupon_params_data[:applicable_categories]&.to_json if coupon_params_data.key?(:applicable_categories)
    update_hash[:applicable_products] = coupon_params_data[:applicable_products]&.to_json if coupon_params_data.key?(:applicable_products)
    update_hash[:applicable_brands] = coupon_params_data[:applicable_brands]&.to_json if coupon_params_data.key?(:applicable_brands)
    update_hash[:applicable_suppliers] = coupon_params_data[:applicable_suppliers]&.to_json if coupon_params_data.key?(:applicable_suppliers)
    
    if @coupon.update(update_hash)
      render_success(format_coupon_detail_data(@coupon), 'Coupon updated successfully')
    else
      render_validation_errors(@coupon.errors.full_messages, 'Coupon update failed')
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

  def format_coupons_data(coupons)
    coupons.map { |coupon| format_coupon_data(coupon) }
  end

  def format_coupon_data(coupon)
    {
      id: coupon.id,
      code: coupon.code,
      name: coupon.name,
      description: coupon.description,
      coupon_type: coupon.coupon_type,
      discount_value: coupon.discount_value.to_f,
      max_discount_amount: coupon.max_discount_amount&.to_f,
      min_order_amount: coupon.min_order_amount.to_f,
      valid_from: coupon.valid_from,
      valid_until: coupon.valid_until,
      is_active: coupon.is_active,
      max_uses: coupon.max_uses,
      max_uses_per_user: coupon.max_uses_per_user,
      current_uses: coupon.current_uses
    }
  end

  def format_coupon_detail_data(coupon)
    format_coupon_data(coupon).merge(
      is_new_user_only: coupon.is_new_user_only,
      is_first_order_only: coupon.is_first_order_only,
      applicable_categories: coupon.applicable_categories_list,
      applicable_products: coupon.applicable_products_list,
      applicable_brands: coupon.applicable_brands_list,
      applicable_suppliers: coupon.applicable_suppliers_list,
      created_at: coupon.created_at,
      updated_at: coupon.updated_at
    )
  end
end


