# frozen_string_literal: true

class SearchSuggestion < ApplicationRecord
  # Suggestion types
  enum :suggestion_type, {
    product: 'product',
    category: 'category',
    brand: 'brand',
    trending: 'trending'
  }
  
  validates :query, presence: true
  validates :suggestion_type, presence: true
  
  scope :active, -> { where(is_active: true) }
  scope :popular, -> { order(search_count: :desc) }
  scope :by_type, ->(type) { where(suggestion_type: type) }
  
  # Increment search count
  def increment_search!
    increment!(:search_count)
  end
  
  # Increment click count
  def increment_click!
    increment!(:click_count)
  end
end

