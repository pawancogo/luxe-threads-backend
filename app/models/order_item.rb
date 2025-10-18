class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product_variant
  has_many :return_items, dependent: :destroy

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price_at_purchase, presence: true, numericality: { greater_than: 0 }
end