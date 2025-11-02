# frozen_string_literal: true

# Service for creating carts
# Extracted from User model callback
class CartCreationService
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def call
    return user.cart if user.cart.present?
    user.create_cart!
  rescue StandardError => e
    Rails.logger.error "CartCreationService failed for user #{user.id}: #{e.message}"
    nil
  end
end

