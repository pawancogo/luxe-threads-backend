class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :destroy

  def total_items
    cart_items.sum(:quantity)
  end

  def total_amount
    cart_items.sum { |item| (item.product_variant.discounted_price || item.product_variant.price) * item.quantity }
  end

  def empty?
    cart_items.empty?
  end
end