# frozen_string_literal: true

class Promotion < ApplicationRecord
  belongs_to :created_by, class_name: 'Admin', optional: true
  
  # Promotion types
  enum promotion_type: {
    flash_sale: 'flash_sale',
    buy_x_get_y: 'buy_x_get_y',
    bundle_deal: 'bundle_deal',
    seasonal_sale: 'seasonal_sale'
  }
  
  validates :name, presence: true
  validates :promotion_type, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  
  validate :end_date_after_start_date
  
  scope :active, -> { where(is_active: true).where('start_date <= ? AND end_date >= ?', Time.current, Time.current) }
  scope :featured, -> { where(is_featured: true) }
  
  def current?
    is_active? && 
    Time.current >= start_date && 
    Time.current <= end_date
  end
  
  # Parse JSON fields
  def applicable_categories_list
    return [] if applicable_categories.blank?
    JSON.parse(applicable_categories) rescue []
  end
  
  def applicable_products_list
    return [] if applicable_products.blank?
    JSON.parse(applicable_products) rescue []
  end
  
  def applicable_brands_list
    return [] if applicable_brands.blank?
    JSON.parse(applicable_brands) rescue []
  end
  
  private
  
  def end_date_after_start_date
    return unless start_date.present? && end_date.present?
    errors.add(:end_date, 'must be after start_date') if end_date <= start_date
  end
end



