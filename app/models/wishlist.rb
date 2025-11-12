# frozen_string_literal: true

class Wishlist < ApplicationRecord
  belongs_to :user
  has_many :wishlist_items, dependent: :destroy
  has_many :product_variants, through: :wishlist_items
  
  # Phase 4: Enhanced wishlist features
  validates :name, presence: true
  validates :user_id, uniqueness: { scope: :is_default, message: "can only have one default wishlist" }, if: :is_default?
  
  scope :public_wishlists, -> { where(is_public: true) }
  scope :default, -> { where(is_default: true) }
  scope :with_items, -> { includes(wishlist_items: { product_variant: { product: [:brand, :category] } }) }
  
  # Include concerns
  include TokenGeneratable
  include SingleDefaultable
  
  # Generate share token
  before_validation :generate_share_token, on: :create, if: -> { share_enabled? && share_token.blank? }
  
  # Ensure only one default wishlist per user
  ensure_single_default_for :is_default, scope: :user_id
  
  # Share URL
  def share_url
    return nil unless share_enabled? && share_token.present?
    "#{ENV['FRONTEND_URL'] || 'http://localhost:5173'}/wishlist/#{share_token}"
  end
  
  private
  
  def generate_share_token
    self.share_token = generate_unique_token_for(:share_token)
  end
end
