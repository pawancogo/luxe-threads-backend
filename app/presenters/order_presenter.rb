# frozen_string_literal: true

# Presenter for Order admin views
# Handles presentation logic for admin panel
class OrderPresenter
  attr_reader :order

  delegate :id, :order_number, :status, :payment_status, :total_amount, :created_at, to: :order

  def initialize(order)
    @order = order
  end

  # Status presentation
  def status_label
    case order.status.to_s
    when 'pending' then 'Pending'
    when 'confirmed' then 'Confirmed'
    when 'processing' then 'Processing'
    when 'shipped' then 'Shipped'
    when 'delivered' then 'Delivered'
    when 'cancelled' then 'Cancelled'
    when 'refunded' then 'Refunded'
    else order.status.to_s.humanize
    end
  end

  def status_badge_class
    {
      'pending' => 'badge-warning',
      'confirmed' => 'badge-info',
      'processing' => 'badge-primary',
      'shipped' => 'badge-info',
      'delivered' => 'badge-success',
      'cancelled' => 'badge-danger',
      'refunded' => 'badge-secondary'
    }[order.status.to_s] || 'badge-secondary'
  end

  def payment_status_label
    case order.payment_status.to_s
    when 'pending' then 'Pending'
    when 'paid' then 'Paid'
    when 'failed' then 'Failed'
    when 'refunded' then 'Refunded'
    else order.payment_status.to_s.humanize
    end
  end

  def payment_status_badge_class
    {
      'pending' => 'badge-warning',
      'paid' => 'badge-success',
      'failed' => 'badge-danger',
      'refunded' => 'badge-secondary'
    }[order.payment_status.to_s] || 'badge-secondary'
  end

  # Customer information
  def customer_name
    order.user&.full_name || 'Unknown Customer'
  end

  def customer_email
    order.user&.email || 'N/A'
  end

  # Address formatting
  def shipping_address_display
    return 'N/A' unless order.shipping_address
    
    addr = order.shipping_address
    "#{addr.line1}, #{addr.city}, #{addr.state} #{addr.postal_code}"
  end

  def billing_address_display
    return 'N/A' unless order.billing_address
    
    addr = order.billing_address
    "#{addr.line1}, #{addr.city}, #{addr.state} #{addr.postal_code}"
  end

  # Financial information
  def formatted_total
    format_currency(order.total_amount, order.currency)
  end

  def formatted_subtotal
    format_currency(order.subtotal || order.total_amount, order.currency)
  end

  def formatted_tax
    format_currency(order.tax_amount || 0, order.currency)
  end

  def formatted_coupon_discount
    return 'N/A' unless order.coupon_discount&.positive?
    format_currency(order.coupon_discount, order.currency)
  end

  # Item information
  def item_count
    order.order_items.sum(:quantity)
  end

  def item_count_label
    "#{item_count} #{'item'.pluralize(item_count)}"
  end

  # Date formatting
  def formatted_created_at
    order.created_at&.strftime('%B %d, %Y at %I:%M %p')
  end

  def formatted_estimated_delivery
    return 'N/A' unless order.estimated_delivery_date
    order.estimated_delivery_date.strftime('%B %d, %Y')
  end

  # Actions
  def can_be_cancelled?
    order.can_be_cancelled?
  end

  def can_be_refunded?
    order.payment_status == 'paid' && ['delivered', 'cancelled'].include?(order.status)
  end

  private

  def format_currency(amount, currency = 'INR')
    return 'N/A' unless amount
    
    case currency
    when 'USD'
      "$#{amount.to_f.round(2)}"
    when 'INR'
      "₹#{amount.to_f.round(2)}"
    else
      "#{amount.to_f.round(2)} #{currency}"
    end
  end
end

