# frozen_string_literal: true

class Api::V1::PromotionsController < ApplicationController
  include AdminApiAuthorization
  
  skip_before_action :authenticate_request, only: [:index, :show]
  before_action :authorize_admin!, only: [:admin_index, :admin_create, :admin_update, :admin_destroy]
  before_action :set_promotion, only: [:show, :admin_update, :admin_destroy]

  # GET /api/v1/promotions
  def index
    service = PromotionListingService.new(Promotion.active, params)
    service.call
    
    if service.success?
      render_success(
        PromotionSerializer.collection(service.promotions),
        'Promotions retrieved successfully'
      )
    else
      render_validation_errors(service.errors, 'Failed to retrieve promotions')
    end
  end

  # GET /api/v1/promotions/:id
  def show
    render_success(
      PromotionSerializer.new(@promotion).as_json,
      'Promotion retrieved successfully'
    )
  end

  # GET /api/v1/admin/promotions
  def admin_index
    base_scope = Promotion.includes(:created_by)
    service = PromotionListingService.new(base_scope, params)
    service.call
    
    if service.success?
      render_success(
        PromotionSerializer.collection(service.promotions),
        'Promotions retrieved successfully'
      )
    else
      render_validation_errors(service.errors, 'Failed to retrieve promotions')
    end
  end

  # POST /api/v1/admin/promotions
  def admin_create
    promotion_params_data = params[:promotion] || {}
    
    service = Promotions::CreationService.new(promotion_params_data, @current_admin)
    service.call
    
    if service.success?
      log_admin_activity('create', 'Promotion', service.promotion.id, service.promotion.previous_changes)
      render_created(
        PromotionSerializer.new(service.promotion).as_json,
        'Promotion created successfully'
      )
    else
      render_validation_errors(service.errors, 'Promotion creation failed')
    end
  end

  # PATCH /api/v1/admin/promotions/:id
  def admin_update
    promotion_params_data = params[:promotion] || {}
    
    service = Promotions::UpdateService.new(@promotion, promotion_params_data)
    service.call
    
    if service.success?
      log_admin_activity('update', 'Promotion', @promotion.id, @promotion.previous_changes)
      render_success(
        PromotionSerializer.new(@promotion.reload).as_json,
        'Promotion updated successfully'
      )
    else
      render_validation_errors(service.errors, 'Promotion update failed')
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

end

