# frozen_string_literal: true

# Service for creating wishlists
# Extracted from User model callback
class WishlistCreationService
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def call
    return user.wishlist if user.wishlist.present?
    user.create_wishlist!
  rescue StandardError => e
    Rails.logger.error "WishlistCreationService failed for user #{user.id}: #{e.message}"
    nil
  end
end

