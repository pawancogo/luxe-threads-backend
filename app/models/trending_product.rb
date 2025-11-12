# frozen_string_literal: true

class TrendingProduct < ApplicationRecord
  belongs_to :product
  belongs_to :category, optional: true
  
  validates :product_id, uniqueness: { scope: :calculated_at, message: "already has trending data for this date" }
  validates :trend_score, numericality: { greater_than_or_equal_to: 0 }
  
  scope :today, -> { where(calculated_at: Date.current.all_day) }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  scope :top_trending, -> { order(trend_score: :desc) }
  
  # Calculate trend score (delegates to service)
  def calculate_trend_score
    service = Products::TrendScoreService.new(self)
    service.call
    service.trend_score
  end
  
  # Update trend score
  before_save :update_trend_score
  
  private
  
  def update_trend_score
    if views_24h.present? || orders_24h.present? || revenue_24h.present?
      service = Products::TrendScoreService.new(self)
      service.call
      self.trend_score = service.trend_score if service.success?
    end
  end
end

