class Address < ApplicationRecord
  belongs_to :user
  has_many :shipping_orders, class_name: 'Order', foreign_key: 'shipping_address_id'
  has_many :billing_orders, class_name: 'Order', foreign_key: 'billing_address_id'

  enum address_type: { shipping: 0, billing: 1 }

  validates :full_name, presence: true
  validates :phone_number, presence: true
  validates :line1, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :postal_code, presence: true
  validates :country, presence: true
end