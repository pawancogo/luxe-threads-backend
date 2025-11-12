# frozen_string_literal: true

class Coupon < ApplicationRecord
  belongs_to :created_by, class_name: 'Admin', optional: true
  
  has_many :coupon_usages, dependent: :destroy
  
  # Coupon types
  enum coupon_type: {
    percentage: 'percentage',
    fixed_amount: 'fixed_amount',
    free_shipping: 'free_shipping',
    buy_one_get_one: 'buy_one_get_one'
  }
  
  validates :code, presence: true, uniqueness: true, format: { with: /\A[A-Z0-9]+\z/i }
  validates :name, presence: true
  validates :coupon_type, presence: true
  validates :discount_value, presence: true, numericality: { greater_than: 0 }
  validates :valid_from, presence: true
  validates :valid_until, presence: true
  
  validate :valid_until_after_valid_from
  
  scope :active, -> { where(is_active: true).where('valid_from <= ? AND valid_until >= ?', Time.current, Time.current) }
  scope :available, -> { active.where('(max_uses IS NULL OR current_uses < max_uses)') }
  
  # Business logic moved to services - these methods are kept for backward compatibility
  # Prefer using Coupons::UserValidationService, Coupons::OrderValidationService, 
  # and Coupons::DiscountCalculationService directly
  
  # Check if coupon is valid for user (delegates to service)
  def valid_for_user?(user)
    service = Coupons::UserValidationService.new(self, user)
    service.call
    service.valid?
  end
  
  # Check if coupon is applicable to order (delegates to service)
  def applicable_to_order?(order)
    service = Coupons::OrderValidationService.new(self, order)
    service.call
    service.applicable?
  end
  
  # Calculate discount amount using value object
  def discount_object
    Discount.new(
      type: coupon_type,
      value: discount_value,
      currency: 'INR'
    )
  end

  # Calculate discount (delegates to service)
  def calculate_discount(order_amount)
    service = Coupons::DiscountCalculationService.new(self, order_amount)
    service.call
    service.discount_amount.to_f
  end
  
  def available?
    is_active? && 
    Time.current >= valid_from && 
    Time.current <= valid_until &&
    (max_uses.nil? || current_uses < max_uses)
  end
  
  # Include JSON parsing concern
  include JsonParseable
  
  # Parse JSON fields using concern
  json_list_parser :applicable_categories, :applicable_products, :applicable_brands,
                   :applicable_suppliers, :exclude_categories, :exclude_products,
                   :applicable_user_ids, :exclude_user_ids
  
  private
  
  def valid_until_after_valid_from
    return unless valid_from.present? && valid_until.present?
    errors.add(:valid_until, 'must be after valid_from') if valid_until <= valid_from
  end
end


