# frozen_string_literal: true

# Service for updating promotions
module Promotions
  class UpdateService < BaseService
    attr_reader :promotion

    def initialize(promotion, promotion_params)
      super()
      @promotion = promotion
      @promotion_params = promotion_params
    end

    def call
      with_transaction do
        update_promotion
      end
      set_result(@promotion)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def update_promotion
      update_hash = {}
      update_hash[:name] = @promotion_params[:name] if @promotion_params.key?(:name)
      update_hash[:description] = @promotion_params[:description] if @promotion_params.key?(:description)
      update_hash[:promotion_type] = @promotion_params[:promotion_type] if @promotion_params.key?(:promotion_type)
      update_hash[:start_date] = @promotion_params[:start_date] if @promotion_params.key?(:start_date)
      update_hash[:end_date] = @promotion_params[:end_date] if @promotion_params.key?(:end_date)
      update_hash[:is_active] = @promotion_params[:is_active] if @promotion_params.key?(:is_active)
      update_hash[:is_featured] = @promotion_params[:is_featured] if @promotion_params.key?(:is_featured)
      update_hash[:applicable_categories] = @promotion_params[:applicable_categories]&.to_json if @promotion_params.key?(:applicable_categories)
      update_hash[:applicable_products] = @promotion_params[:applicable_products]&.to_json if @promotion_params.key?(:applicable_products)
      update_hash[:applicable_brands] = @promotion_params[:applicable_brands]&.to_json if @promotion_params.key?(:applicable_brands)
      update_hash[:applicable_suppliers] = @promotion_params[:applicable_suppliers]&.to_json if @promotion_params.key?(:applicable_suppliers)
      update_hash[:discount_percentage] = @promotion_params[:discount_percentage] if @promotion_params.key?(:discount_percentage)
      update_hash[:discount_amount] = @promotion_params[:discount_amount] if @promotion_params.key?(:discount_amount)
      update_hash[:min_order_amount] = @promotion_params[:min_order_amount] if @promotion_params.key?(:min_order_amount)
      update_hash[:max_discount_amount] = @promotion_params[:max_discount_amount] if @promotion_params.key?(:max_discount_amount)
      
      unless @promotion.update(update_hash)
        add_errors(@promotion.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @promotion
      end
    end
  end
end

