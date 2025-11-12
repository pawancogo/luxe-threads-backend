class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :destroy

  # Ecommerce-specific scopes
  scope :with_cart_items, -> { includes(cart_items: { product_variant: { product: [:brand, :category, product_variants: :product_images] } }) }
  scope :non_empty, -> { joins(:cart_items).distinct }
  scope :for_customer, ->(customer) { where(user: customer) }

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