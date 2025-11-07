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
  
  # Generate share token
  before_validation :generate_share_token, on: :create, if: -> { share_enabled? && share_token.blank? }
  
  # Ensure only one default wishlist per user
  before_save :ensure_single_default
  
  # Share URL
  def share_url
    return nil unless share_enabled? && share_token.present?
    "#{ENV['FRONTEND_URL'] || 'http://localhost:5173'}/wishlist/#{share_token}"
  end
  
  private
  
  def generate_share_token
    self.share_token = SecureRandom.urlsafe_base64(32)
  end
  
  def ensure_single_default
    return unless is_default?
    
    # Unset other default wishlists for this user
    Wishlist.where(user_id: user_id)
            .where.not(id: id)
            .update_all(is_default: false)
  end
end
