# frozen_string_literal: true

class Api::V1::PromotionsController < ApplicationController
  include AdminApiAuthorization
  
  skip_before_action :authenticate_request, only: [:index, :show]
  before_action :authorize_admin!, only: [:admin_index, :admin_create, :admin_update, :admin_destroy]
  before_action :set_promotion, only: [:show, :admin_update, :admin_destroy]

  # GET /api/v1/promotions
  def index
    @promotions = Promotion.active.order(created_at: :desc)
    
    # Filter by promotion_type if provided
    @promotions = @promotions.where(promotion_type: params[:promotion_type]) if params[:promotion_type].present?
    
    # Filter featured only if requested
    @promotions = @promotions.featured if params[:featured] == 'true'
    
    render_success(format_promotions_data(@promotions), 'Promotions retrieved successfully')
  end

  # GET /api/v1/promotions/:id
  def show
    render_success(format_promotion_detail_data(@promotion), 'Promotion retrieved successfully')
  end

  # GET /api/v1/admin/promotions
  def admin_index
    @promotions = Promotion.includes(:created_by).order(created_at: :desc)
    
    # Filter by status if provided
    @promotions = @promotions.where(is_active: params[:is_active] == 'true') if params[:is_active].present?
    
    # Filter by promotion_type if provided
    @promotions = @promotions.where(promotion_type: params[:promotion_type]) if params[:promotion_type].present?
    
    render_success(format_promotions_data(@promotions), 'Promotions retrieved successfully')
  end

  # POST /api/v1/admin/promotions
  def admin_create
    promotion_params_data = params[:promotion] || {}
    
    @promotion = Promotion.new(
      name: promotion_params_data[:name],
      description: promotion_params_data[:description],
      promotion_type: promotion_params_data[:promotion_type],
      start_date: promotion_params_data[:start_date],
      end_date: promotion_params_data[:end_date],
      is_active: promotion_params_data[:is_active] != false,
      is_featured: promotion_params_data[:is_featured] || false,
      applicable_categories: promotion_params_data[:applicable_categories]&.to_json,
      applicable_products: promotion_params_data[:applicable_products]&.to_json,
      applicable_brands: promotion_params_data[:applicable_brands]&.to_json,
      applicable_suppliers: promotion_params_data[:applicable_suppliers]&.to_json,
      discount_percentage: promotion_params_data[:discount_percentage],
      discount_amount: promotion_params_data[:discount_amount],
      min_order_amount: promotion_params_data[:min_order_amount],
      max_discount_amount: promotion_params_data[:max_discount_amount],
      created_by: @current_admin
    )
    
    if @promotion.save
      log_admin_activity('create', 'Promotion', @promotion.id, @promotion.previous_changes)
      render_created(format_promotion_detail_data(@promotion), 'Promotion created successfully')
    else
      render_validation_errors(@promotion.errors.full_messages, 'Promotion creation failed')
    end
  end

  # PATCH /api/v1/admin/promotions/:id
  def admin_update
    promotion_params_data = params[:promotion] || {}
    
    update_hash = {}
    update_hash[:name] = promotion_params_data[:name] if promotion_params_data.key?(:name)
    update_hash[:description] = promotion_params_data[:description] if promotion_params_data.key?(:description)
    update_hash[:promotion_type] = promotion_params_data[:promotion_type] if promotion_params_data.key?(:promotion_type)
    update_hash[:start_date] = promotion_params_data[:start_date] if promotion_params_data.key?(:start_date)
    update_hash[:end_date] = promotion_params_data[:end_date] if promotion_params_data.key?(:end_date)
    update_hash[:is_active] = promotion_params_data[:is_active] if promotion_params_data.key?(:is_active)
    update_hash[:is_featured] = promotion_params_data[:is_featured] if promotion_params_data.key?(:is_featured)
    update_hash[:applicable_categories] = promotion_params_data[:applicable_categories]&.to_json if promotion_params_data.key?(:applicable_categories)
    update_hash[:applicable_products] = promotion_params_data[:applicable_products]&.to_json if promotion_params_data.key?(:applicable_products)
    update_hash[:applicable_brands] = promotion_params_data[:applicable_brands]&.to_json if promotion_params_data.key?(:applicable_brands)
    update_hash[:applicable_suppliers] = promotion_params_data[:applicable_suppliers]&.to_json if promotion_params_data.key?(:applicable_suppliers)
    update_hash[:discount_percentage] = promotion_params_data[:discount_percentage] if promotion_params_data.key?(:discount_percentage)
    update_hash[:discount_amount] = promotion_params_data[:discount_amount] if promotion_params_data.key?(:discount_amount)
    update_hash[:min_order_amount] = promotion_params_data[:min_order_amount] if promotion_params_data.key?(:min_order_amount)
    update_hash[:max_discount_amount] = promotion_params_data[:max_discount_amount] if promotion_params_data.key?(:max_discount_amount)
    
    if @promotion.update(update_hash)
      log_admin_activity('update', 'Promotion', @promotion.id, @promotion.previous_changes)
      render_success(format_promotion_detail_data(@promotion), 'Promotion updated successfully')
    else
      render_validation_errors(@promotion.errors.full_messages, 'Promotion update failed')
    end
  end

  # DELETE /api/v1/admin/promotions/:id
  def admin_destroy
    promotion_id = @promotion.id
    if @promotion.destroy
      log_admin_activity('destroy', 'Promotion', promotion_id)
      render_success({ id: promotion_id }, 'Promotion deleted successfully')
    else
      render_validation_errors(@promotion.errors.full_messages, 'Promotion deletion failed')
    end
  end

  private

  def set_promotion
    @promotion = Promotion.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found('Promotion not found')
  end

  # authorize_admin! is now handled by AdminApiAuthorization concern

  def format_promotions_data(promotions)
    promotions.map { |promotion| format_promotion_data(promotion) }
  end

  def format_promotion_data(promotion)
    {
      id: promotion.id,
      name: promotion.name,
      description: promotion.description,
      promotion_type: promotion.promotion_type,
      start_date: promotion.start_date,
      end_date: promotion.end_date,
      is_active: promotion.is_active,
      is_featured: promotion.is_featured,
      discount_percentage: promotion.discount_percentage&.to_f,
      discount_amount: promotion.discount_amount&.to_f,
      min_order_amount: promotion.min_order_amount&.to_f,
      current?: promotion.current?
    }
  end

  def format_promotion_detail_data(promotion)
    format_promotion_data(promotion).merge(
      applicable_categories: promotion.applicable_categories_list,
      applicable_products: promotion.applicable_products_list,
      applicable_brands: promotion.applicable_brands_list,
      max_discount_amount: promotion.max_discount_amount&.to_f,
      created_at: promotion.created_at,
      updated_at: promotion.updated_at
    )
  end
end

