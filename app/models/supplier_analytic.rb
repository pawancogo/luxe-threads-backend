# frozen_string_literal: true

class SupplierAnalytic < ApplicationRecord
  self.table_name = 'supplier_analytics'
  
  belongs_to :supplier_profile
  
  validates :date, presence: true, uniqueness: { scope: :supplier_profile_id }
  validates :total_orders, numericality: { greater_than_or_equal_to: 0 }
  validates :total_revenue, numericality: { greater_than_or_equal_to: 0 }
  validates :conversion_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  
  scope :recent, -> { order(date: :desc) }
  scope :by_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }
  
  # Calculate conversion rate
  def calculate_conversion_rate
    return 0.0 if products_viewed.zero?
    ((products_added_to_cart.to_f / products_viewed) * 100).round(2)
  end
  
  # Update conversion rate
  before_save :update_conversion_rate
  
  private
  
  def update_conversion_rate
    self.conversion_rate = calculate_conversion_rate if products_viewed.present? && products_added_to_cart.present?
  end
end

