# frozen_string_literal: true

# Serializer for User Profile API responses (includes additional stats)
class UserProfileSerializer < BaseSerializer
  attributes :id, :first_name, :last_name, :full_name, :email, :phone_number,
             :role, :email_verified, :referral_code, :addresses_count,
             :orders_count, :cart_items_count, :wishlist_items_count,
             :created_at, :updated_at

  def email_verified
    object.email_verified?
  end

  def referral_code
    object.referral_code || object.generate_referral_code
  end

  def addresses_count
    object.addresses.count
  end

  def orders_count
    object.orders.count
  end

  def cart_items_count
    object.cart&.cart_items&.count || 0
  end

  def wishlist_items_count
    object.wishlist&.wishlist_items&.count || 0
  end
end

