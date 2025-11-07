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
  
  # Check if coupon is valid for user
  def valid_for_user?(user)
    return false unless available?
    return false if new_users_only? && user.created_at > valid_from
    return false if first_order_only? && user.orders.exists?
    
    # Check user restrictions
    if applicable_user_ids_list.present?
      return false unless applicable_user_ids_list.include?(user.id)
    end
    
    if exclude_user_ids_list.present?
      return false if exclude_user_ids_list.include?(user.id)
    end
    
    # Check usage limits
    if max_uses_per_user.present?
      return false if coupon_usages.where(user: user).count >= max_uses_per_user
    end
    
    true
  end
  
  # Check if coupon is applicable to order
  def applicable_to_order?(order)
    return false unless valid_for_user?(order.user)
    
    # Check minimum order amount
    return false if min_order_amount.present? && order.total_amount < min_order_amount
    
    # Check category/product/brand restrictions
    order_items = order.order_items
    applicable = false
    
    if applicable_categories_list.present?
      applicable ||= order_items.joins(product: :category).where(categories: { id: applicable_categories_list }).exists?
    end
    
    if applicable_products_list.present?
      applicable ||= order_items.where(product_id: applicable_products_list).exists?
    end
    
    if applicable_brands_list.present?
      applicable ||= order_items.joins(product: :brand).where(brands: { id: applicable_brands_list }).exists?
    end
    
    # Check exclusions
    if exclude_categories_list.present?
      return false if order_items.joins(product: :category).where(categories: { id: exclude_categories_list }).exists?
    end
    
    if exclude_products_list.present?
      return false if order_items.where(product_id: exclude_products_list).exists?
    end
    
    applicable || applicable_categories_list.blank? && applicable_products_list.blank? && applicable_brands_list.blank?
  end
  
  # Calculate discount amount using value object
  def discount_object
    Discount.new(
      type: coupon_type,
      value: discount_value,
      currency: 'INR'
    )
  end

  def calculate_discount(order_amount)
    discount = discount_object.calculate(BigDecimal(order_amount.to_s))
    
    # Apply max discount limit if present
    if max_discount_amount.present? && discount > max_discount_amount
      discount = max_discount_amount
    end
    
    discount.to_f
  end
  
  def available?
    is_active? && 
    Time.current >= valid_from && 
    Time.current <= valid_until &&
    (max_uses.nil? || current_uses < max_uses)
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
  
  def applicable_suppliers_list
    return [] if applicable_suppliers.blank?
    JSON.parse(applicable_suppliers) rescue []
  end
  
  def exclude_categories_list
    return [] if exclude_categories.blank?
    JSON.parse(exclude_categories) rescue []
  end
  
  def exclude_products_list
    return [] if exclude_products.blank?
    JSON.parse(exclude_products) rescue []
  end
  
  def applicable_user_ids_list
    return [] if applicable_user_ids.blank?
    JSON.parse(applicable_user_ids) rescue []
  end
  
  def exclude_user_ids_list
    return [] if exclude_user_ids.blank?
    JSON.parse(exclude_user_ids) rescue []
  end
  
  private
  
  def valid_until_after_valid_from
    return unless valid_from.present? && valid_until.present?
    errors.add(:valid_until, 'must be after valid_from') if valid_until <= valid_from
  end
end


