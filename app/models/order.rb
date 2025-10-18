class Order < ApplicationRecord
  belongs_to :user
  belongs_to :shipping_address, class_name: 'Address'
  belongs_to :billing_address, class_name: 'Address'
  has_many :order_items, dependent: :destroy
  has_many :product_variants, through: :order_items
  has_many :return_requests, dependent: :destroy

  enum status: { pending: 0, paid: 1, packed: 2, shipped: 3, delivered: 4, cancelled: 5 }
  enum payment_status: { pending: 0, complete: 1, failed: 2 }

  validates :total_amount, presence: true, numericality: { greater_than: 0 }
end