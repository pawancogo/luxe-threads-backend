class Order < ApplicationRecord
  extend SearchManager
  
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

  # Phase 2: Callbacks
  before_validation :generate_order_number, if: -> { order_number.blank? }
  after_create :send_order_confirmation_email
  after_update :update_status_history, if: -> { saved_change_to_status? }
  after_update :send_status_notification_email, if: -> { saved_change_to_status? }

  # Phase 2: Scopes
  scope :by_order_number, ->(number) { where(order_number: number) }
  scope :recent, -> { order(created_at: :desc) }

  # Phase 2: JSON field helpers
  def status_history_array
    return [] if status_history.blank?
    JSON.parse(status_history) rescue []
  end

  # Phase 2: Update status history
  def update_status_history
    history = status_history_array
    history << {
      'status' => status,
      'timestamp' => Time.current.iso8601,
      'note' => 'Status updated'
    }
    update_column(:status_history, history.to_json)
    update_column(:status_updated_at, Time.current)
  end

  # Check if order can be cancelled
  def can_be_cancelled?
    return false if cancelled?
    return false if shipped? || delivered?
    # Can cancel if pending or paid (before shipment)
    pending? || paid?
  end

  # Cancel order with reason
  def cancel!(reason, cancelled_by = 'customer')
    raise StandardError, 'Order cannot be cancelled' unless can_be_cancelled?

    ActiveRecord::Base.transaction do
      # Restore inventory for all order items
      order_items.each do |item|
        variant = item.product_variant
        # Restore stock quantity
        variant.increment!(:stock_quantity, item.quantity)
        # Decrease reserved quantity
        variant.decrement!(:reserved_quantity, item.quantity) if variant.reserved_quantity.to_i > 0
        variant.update_availability_flags
        
        # Update order item fulfillment status
        item.update!(fulfillment_status: 'cancelled')
      end

      # Update order status
      self.status = 'cancelled'
      self.cancellation_reason = reason
      self.cancelled_at = Time.current
      self.cancelled_by = cancelled_by
      save!

      # Update status history
      history = status_history_array
      history << {
        'status' => 'cancelled',
        'timestamp' => Time.current.iso8601,
        'note' => "Cancelled by #{cancelled_by}: #{reason}"
      }
      update_column(:status_history, history.to_json)
      update_column(:status_updated_at, Time.current)

      # Send cancellation email
      begin
        OrderMailer.order_cancelled(self).deliver_now
      rescue StandardError => e
        Rails.logger.error "Failed to send cancellation email: #{e.message}"
      end

      # Trigger refund if payment was completed
      if payment_status == 'payment_complete' && payments.any?
        # TODO: Integrate with payment gateway to process refund
        # For now, just log that refund should be processed
        Rails.logger.info "Order #{id} cancelled - Refund should be processed for payment #{payments.first.id}"
        # Could create a PaymentRefund record here
      end
    end
  end

  private

  def generate_order_number
    return if order_number.present?
    date = Date.current.strftime('%Y%m%d')
    sequence = Order.where("order_number LIKE ?", "ORD-#{date}-%").count + 1
    self.order_number = "ORD-#{date}-#{sequence.to_s.rjust(8, '0')}"
  end

  def send_order_confirmation_email
    begin
      OrderMailer.order_confirmation(self).deliver_now
    rescue StandardError => e
      Rails.logger.error "Failed to send order confirmation email: #{e.message}"
      # Don't fail order creation if email fails
    end
  end

  def send_status_notification_email
    case status
    when 'shipped'
      begin
        OrderMailer.order_shipped(self).deliver_now
      rescue StandardError => e
        Rails.logger.error "Failed to send shipping notification email: #{e.message}"
      end
    when 'delivered'
      begin
        OrderMailer.order_delivered(self).deliver_now
      rescue StandardError => e
        Rails.logger.error "Failed to send delivery notification email: #{e.message}"
      end
    end
  end
end