# frozen_string_literal: true

# Service for calculating trend score for trending products
# Extracted from TrendingProduct model to follow SOLID principles
module Products
  class TrendScoreService < BaseService
    attr_reader :trend_score

    def initialize(trending_product)
      super()
      @trending_product = trending_product
    end

    def call
      calculate_trend_score
      set_result(@trend_score)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def calculate_trend_score
      views_24h = @trending_product.views_24h || 0
      orders_24h = @trending_product.orders_24h || 0
      revenue_24h = @trending_product.revenue_24h || 0

      # Simple scoring algorithm - can be enhanced
      @trend_score = ((views_24h * 0.3) + (orders_24h * 10) + (revenue_24h.to_f * 0.1)).round(2)
    end
  end
end

