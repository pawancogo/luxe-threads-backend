# frozen_string_literal: true

# Service for creating reviews
module Reviews
  class CreationService < BaseService
    attr_reader :review

    def initialize(product, user, review_params)
      super()
      @product = product
      @user = user
      @review_params = review_params
    end

    def call
      find_order_item
      create_review
      set_result(@review)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def find_order_item
      # Check if user has purchased this product (for verified purchase)
      @order_item = @user.orders.joins(:order_items)
                        .where(order_items: { product_variant_id: @product.product_variants.pluck(:id) })
                        .order('orders.created_at DESC')
                        .first&.order_items&.find_by(product_variant_id: @product.product_variants.pluck(:id))
    end

    def create_review
      @review = @product.reviews.build(@review_params)
      @review.user = @user
      @review.order_item = @order_item
      @review.moderation_status = 'pending' # Default to pending moderation
      
      unless @review.save
        add_errors(@review.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @review
      end
    end
  end
end

