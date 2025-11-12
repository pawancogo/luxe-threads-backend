# frozen_string_literal: true

# Service for creating promotions
module Promotions
  class CreationService < BaseService
    attr_reader :promotion

    def initialize(promotion_params, created_by)
      super()
      @promotion_params = promotion_params
      @created_by = created_by
    end

    def call
      with_transaction do
        create_promotion
      end
      set_result(@promotion)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def create_promotion
      @promotion = Promotion.new(
        name: @promotion_params[:name],
        description: @promotion_params[:description],
        promotion_type: @promotion_params[:promotion_type],
        start_date: @promotion_params[:start_date],
        end_date: @promotion_params[:end_date],
        is_active: @promotion_params[:is_active] != false,
        is_featured: @promotion_params[:is_featured] || false,
        applicable_categories: @promotion_params[:applicable_categories]&.to_json,
        applicable_products: @promotion_params[:applicable_products]&.to_json,
        applicable_brands: @promotion_params[:applicable_brands]&.to_json,
        applicable_suppliers: @promotion_params[:applicable_suppliers]&.to_json,
        discount_percentage: @promotion_params[:discount_percentage],
        discount_amount: @promotion_params[:discount_amount],
        min_order_amount: @promotion_params[:min_order_amount],
        max_discount_amount: @promotion_params[:max_discount_amount],
        created_by: @created_by
      )
      
      unless @promotion.save
        add_errors(@promotion.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @promotion
      end
    end
  end
end

