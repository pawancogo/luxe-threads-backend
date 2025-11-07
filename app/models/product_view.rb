# frozen_string_literal: true

class ProductView < ApplicationRecord
  belongs_to :product
  belongs_to :user, optional: true
  belongs_to :product_variant, optional: true
  
  # Source types
  enum :source, {
    search: 'search',
    category: 'category',
    brand: 'brand',
    direct: 'direct',
    recommendation: 'recommendation'
  }, default: 'direct'
  
  scope :recent, -> { order(viewed_at: :desc) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_product, ->(product_id) { where(product_id: product_id) }
  
  # Track view
  def self.track_view(product_id, options = {})
    create(
      product_id: product_id,
      user_id: options[:user_id],
      product_variant_id: options[:product_variant_id],
      session_id: options[:session_id],
      ip_address: options[:ip_address],
      user_agent: options[:user_agent],
      referrer_url: options[:referrer_url],
      source: options[:source] || 'direct',
      viewed_at: Time.current
    )
  end
end

