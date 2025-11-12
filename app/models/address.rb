class Address < ApplicationRecord
  belongs_to :user
  has_many :shipping_orders, class_name: 'Order', foreign_key: 'shipping_address_id', dependent: :nullify
  has_many :billing_orders, class_name: 'Order', foreign_key: 'billing_address_id', dependent: :nullify

  enum :address_type, { shipping: 'shipping', billing: 'billing' }
  
  # Include concern for single default behavior
  include SingleDefaultable
  
  # Before destroying address, nullify order references
  before_destroy :nullify_order_references
  
  # Ensure only one default shipping and one default billing address per user
  ensure_single_default_for :is_default_shipping, scope: :user_id
  ensure_single_default_for :is_default_billing, scope: :user_id

  validates :full_name, presence: true
  validates :phone_number, presence: true
  validates :line1, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :postal_code, presence: true
  validates :country, presence: true
  
  scope :default_shipping, -> { where(is_default_shipping: true) }
  scope :default_billing, -> { where(is_default_billing: true) }
  
  private
  
  def nullify_order_references
    # Nullify shipping and billing address references in orders
    Order.where(shipping_address_id: id).update_all(shipping_address_id: nil)
    Order.where(billing_address_id: id).update_all(billing_address_id: nil)
  end
end