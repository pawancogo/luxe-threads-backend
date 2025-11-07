# frozen_string_literal: true

class TrendingProduct < ApplicationRecord
  belongs_to :product
  belongs_to :category, optional: true
  
  validates :product_id, uniqueness: { scope: :calculated_at, message: "already has trending data for this date" }
  validates :trend_score, numericality: { greater_than_or_equal_to: 0 }
  
  scope :today, -> { where(calculated_at: Date.current.all_day) }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  scope :top_trending, -> { order(trend_score: :desc) }
  
  # Calculate trend score
  def calculate_trend_score
    # Simple scoring algorithm - can be enhanced
    score = (views_24h * 0.3) + (orders_24h * 10) + (revenue_24h.to_f * 0.1)
    score.round(2)
  end
  
  # Update trend score
  before_save :update_trend_score
  
  private
  
  def update_trend_score
    self.trend_score = calculate_trend_score if views_24h.present? || orders_24h.present? || revenue_24h.present?
  end
end

