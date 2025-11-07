class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product_variant
  belongs_to :supplier_profile
  has_many :return_items, dependent: :destroy
  
  # Phase 3: Additional associations
  has_many :reviews, dependent: :nullify
  has_many :return_requests, dependent: :destroy
  has_many :shipments, dependent: :destroy
  has_many :payment_refunds, dependent: :destroy

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price_at_purchase, presence: true, numericality: { greater_than: 0 }

  # Phase 2: Enums
  enum :fulfillment_status, {
    pending: 'pending',
    processing: 'processing',
    packed: 'packed',
    shipped: 'shipped',
    delivered: 'delivered',
    cancelled: 'cancelled',
    returned: 'returned',
    refunded: 'refunded'
  }, default: 'pending'

  # Phase 2: Scopes
  scope :by_supplier, ->(supplier_id) { where(supplier_profile_id: supplier_id) }
  scope :shipped, -> { where(fulfillment_status: 'shipped') }
  scope :delivered, -> { where(fulfillment_status: 'delivered') }
  scope :returnable, -> { where(is_returnable: true).where('return_deadline >= ?', Date.current) }

  # Phase 2: Callbacks
  before_save :set_final_price, if: -> { final_price.blank? }
  after_create :set_return_deadline

  # Phase 2: JSON field helpers
  def product_variant_attributes_hash
    return {} if product_variant_attributes.blank?
    JSON.parse(product_variant_attributes) rescue {}
  end

  # Phase 2: Business logic using value objects
  def price_object
    Price.new(
      price_at_purchase,
      discounted_price: discounted_price,
      currency: 'INR'
    )
  end

  def subtotal
    price_object.total(quantity)
  end

  def can_return?
    is_returnable && return_deadline >= Date.current && !return_requested
  end

  private

  def set_final_price
    self.final_price = discounted_price || price_at_purchase
  end

  def set_return_deadline
    return if return_deadline.present?
    self.return_deadline = order.created_at.to_date + 30.days
    save
  end
end