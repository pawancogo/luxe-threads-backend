# frozen_string_literal: true

class Admin::CouponsController < Admin::BaseController
    before_action :set_coupon, only: [:show, :edit, :update, :destroy]

    def index
      @coupons = Coupon.order(created_at: :desc).page(params[:page])
      @coupons = @coupons.where(is_active: params[:is_active] == 'true') if params[:is_active].present?
      @coupons = @coupons.where(coupon_type: params[:coupon_type]) if params[:coupon_type].present?
    end

    def show
    end

    def new
      @coupon = Coupon.new
    end

    def create
      service = Coupons::CreationService.new(coupon_params)
      service.call
      
      if service.success?
        redirect_to admin_coupon_path(service.coupon), notice: 'Coupon created successfully.'
      else
        @coupon = service.coupon || Coupon.new(coupon_params)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      service = Coupons::UpdateService.new(@coupon, coupon_params)
      service.call
      
      if service.success?
        redirect_to admin_coupon_path(@coupon), notice: 'Coupon updated successfully.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      service = Coupons::DeletionService.new(@coupon)
      service.call
      
      if service.success?
        redirect_to admin_coupons_path, notice: 'Coupon deleted successfully.'
      else
        redirect_to admin_coupons_path, alert: service.errors.first || 'Failed to delete coupon'
      end
    end

    private

    def set_coupon
      @coupon = Coupon.find(params[:id])
    end

    def coupon_params
      params.require(:coupon).permit(
        :code, :name, :description, :coupon_type, :discount_value,
        :max_discount_amount, :min_order_amount, :valid_from, :valid_until,
        :is_active, :max_uses, :max_uses_per_user, :is_new_user_only,
        :is_first_order_only,
        applicable_categories: [], applicable_products: [],
        applicable_brands: [], applicable_suppliers: []
      )
    end
  end

