# frozen_string_literal: true

class Admin::PromotionsController < Admin::BaseController
    before_action :set_promotion, only: [:show, :edit, :update, :destroy]

    def index
      @promotions = Promotion.includes(:created_by).order(created_at: :desc).page(params[:page])
      @promotions = @promotions.where(is_active: params[:is_active] == 'true') if params[:is_active].present?
      @promotions = @promotions.where(promotion_type: params[:promotion_type]) if params[:promotion_type].present?
    end

    def show
    end

    def new
      @promotion = Promotion.new
    end

    def create
      service = Promotions::CreationService.new(promotion_params, current_admin)
      service.call
      
      if service.success?
        redirect_to admin_promotion_path(service.promotion), notice: 'Promotion created successfully.'
      else
        @promotion = service.promotion || Promotion.new(promotion_params)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      service = Promotions::UpdateService.new(@promotion, promotion_params)
      service.call
      
      if service.success?
        redirect_to admin_promotion_path(@promotion), notice: 'Promotion updated successfully.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      service = Promotions::DeletionService.new(@promotion)
      service.call
      
      if service.success?
        redirect_to admin_promotions_path, notice: 'Promotion deleted successfully.'
      else
        redirect_to admin_promotions_path, alert: service.errors.first || 'Failed to delete promotion'
      end
    end

    private

    def set_promotion
      @promotion = Promotion.find(params[:id])
    end

    def promotion_params
      params.require(:promotion).permit(
        :name, :description, :promotion_type, :start_date, :end_date,
        :is_active, :is_featured, :discount_percentage, :discount_amount,
        :min_order_amount, :max_discount_amount, :banner_image_url,
        applicable_categories: [], applicable_products: [],
        applicable_brands: [], applicable_suppliers: []
      )
    end
  end

