class Order < ApplicationRecord
  extend SearchManager
  
  # Include concerns
  include StatusTrackable
  
  # PaperTrail for audit logging
  has_paper_trail
  
  # Soft delete functionality
  acts_as_paranoid
  
  # Search manager configuration
  search_manager on: [:order_number], aggs_on: [:status, :payment_status]
  
  belongs_to :user, counter_cache: :orders_count
  belongs_to :shipping_address, class_name: 'Address', foreign_key: 'shipping_address_id'
  belongs_to :billing_address, class_name: 'Address', foreign_key: 'billing_address_id'
  has_many :order_items, dependent: :destroy
  has_many :product_variants, through: :order_items
  has_many :return_requests, dependent: :destroy
  
  # Phase 3: Payment & Shipping associations
  has_many :payments, dependent: :destroy
  has_many :payment_refunds, dependent: :destroy
  has_many :payment_transactions, dependent: :destroy
  has_many :shipments, dependent: :destroy
  has_many :coupon_usages, dependent: :destroy

  enum :status, { pending: 'pending', paid: 'paid', packed: 'packed', shipped: 'shipped', delivered: 'delivered', cancelled: 'cancelled' }
  enum :payment_status, { payment_pending: 'payment_pending', payment_complete: 'payment_complete', payment_failed: 'payment_failed' }

  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :order_number, uniqueness: true, allow_nil: true

  # Callbacks
  before_validation :generate_order_number, if: -> { order_number.blank? }
  after_update :update_status_history, if: -> { saved_change_to_status? }

  # Ecommerce-specific scopes
  scope :by_order_number, ->(number) { where(order_number: number) }
  scope :search_by_order_number, ->(term) { where('order_number LIKE ?', "%#{term}%") if term.present? }
  scope :recent, -> { order(created_at: :desc) }
  scope :recent_by_days, ->(days = 30) { where('created_at >= ?', days.days.ago) }
  scope :for_customer, ->(user) { where(user: user) }
  scope :for_user, ->(user_id) { where(user_id: user_id) if user_id.present? }
  scope :by_status, ->(status) { where(status: status) }
  scope :with_status, ->(status) { where(status: status) if status.present? }
  scope :with_payment_status, ->(payment_status) { where(payment_status: payment_status) if payment_status.present? }
  scope :cancellable_by_customer, ->(customer) { where(user: customer).where.not(status: ['cancelled', 'delivered', 'shipped']) }
  scope :pending_payment, -> { where(payment_status: 'payment_pending') }
  scope :paid, -> { where(payment_status: 'payment_complete') }
  scope :ready_to_ship, -> { where(status: 'paid') }
  scope :shipped, -> { where(status: 'shipped') }
  scope :delivered, -> { where(status: 'delivered') }
  scope :with_full_details, -> { includes(:user, :shipping_address, :billing_address, order_items: [:product_variant]) }
  scope :with_items, -> { includes(:order_items) }
  scope :created_from, ->(date) { where('created_at >= ?', date) if date.present? }
  scope :created_to, ->(date) { where('created_at <= ?', date) if date.present? }
  scope :created_between, ->(from, to) { created_from(from).created_to(to) }
  scope :min_amount, ->(amount) { where('total_amount >= ?', amount) if amount.present? }
  scope :max_amount, ->(amount) { where('total_amount <= ?', amount) if amount.present? }
  scope :amount_between, ->(min, max) { min_amount(min).max_amount(max) }

  # Status history is handled by StatusTrackable concern

  # Check if order can be cancelled
  def can_be_cancelled?
    return false if cancelled?
    return false if shipped? || delivered?
    # Can cancel if pending or paid (before shipment)
    pending? || paid?
  end

  # Business logic moved to OrderCancellationService
  # This method is kept for backward compatibility but should not be used directly
  # Use Orders::CancellationService instead

  private

  def generate_order_number
    return if order_number.present?
    date = Date.current.strftime('%Y%m%d')
    sequence = Order.where("order_number LIKE ?", "ORD-#{date}-%").count + 1
    self.order_number = "ORD-#{date}-#{sequence.to_s.rjust(8, '0')}"
  end
end