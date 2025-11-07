class Address < ApplicationRecord
  belongs_to :user
  has_many :shipping_orders, class_name: 'Order', foreign_key: 'shipping_address_id', dependent: :nullify
  has_many :billing_orders, class_name: 'Order', foreign_key: 'billing_address_id', dependent: :nullify

  enum :address_type, { shipping: 'shipping', billing: 'billing' }
  
  # Before destroying address, nullify order references
  before_destroy :nullify_order_references
  
  # Ensure only one default shipping and one default billing address per user
  before_save :ensure_single_default_shipping, if: :will_save_change_to_is_default_shipping?
  before_save :ensure_single_default_billing, if: :will_save_change_to_is_default_billing?

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
  
  def ensure_single_default_shipping
    return unless is_default_shipping?
    
    # Unset other default shipping addresses for this user
    Address.where(user_id: user_id)
           .where.not(id: id)
           .where(is_default_shipping: true)
           .update_all(is_default_shipping: false)
  end
  
  def ensure_single_default_billing
    return unless is_default_billing?
    
    # Unset other default billing addresses for this user
    Address.where(user_id: user_id)
           .where.not(id: id)
           .where(is_default_billing: true)
           .update_all(is_default_billing: false)
  end
end