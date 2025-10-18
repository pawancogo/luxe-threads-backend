class Order < ApplicationRecord
  belongs_to :user
  belongs_to :shipping_address, class_name: 'Address', foreign_key: 'shipping_address_id'
  belongs_to :billing_address, class_name: 'Address', foreign_key: 'billing_address_id'
  has_many :order_items, dependent: :destroy
  has_many :product_variants, through: :order_items
  has_many :return_requests, dependent: :destroy

  enum :status, { pending: 'pending', paid: 'paid', packed: 'packed', shipped: 'shipped', delivered: 'delivered', cancelled: 'cancelled' }
  enum :payment_status, { payment_pending: 'payment_pending', payment_complete: 'payment_complete', payment_failed: 'payment_failed' }

  validates :total_amount, presence: true, numericality: { greater_than: 0 }
end