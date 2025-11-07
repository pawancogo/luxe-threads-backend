# frozen_string_literal: true

class OrderMailer < ApplicationMailer
  default from: 'noreply@luxethreads.com'

  # Order confirmation email
  def order_confirmation(order)
    @order = order
    @user = order.user
    @order_items = order.order_items.includes(product_variant: { product: [:brand, :category] })
    
    mail(
      to: @user.email,
      subject: "Order Confirmation - #{order.order_number}",
      from: "#{Rails.application.config.mailer_from_name || 'LuxeThreads'} <#{Rails.application.config.mailer_from_email || 'noreply@luxethreads.com'}>"
    )
  end

  # Order shipped notification
  def order_shipped(order, shipment = nil)
    @order = order
    @user = order.user
    @shipment = shipment || order.shipments.first
    @tracking_number = @shipment&.tracking_number || order.tracking_number
    @tracking_url = @shipment&.tracking_url || order.tracking_url
    @estimated_delivery = @shipment&.estimated_delivery_date || order.estimated_delivery_date
    
    mail(
      to: @user.email,
      subject: "Your Order #{order.order_number} has been Shipped!",
      from: "#{Rails.application.config.mailer_from_name || 'LuxeThreads'} <#{Rails.application.config.mailer_from_email || 'noreply@luxethreads.com'}>"
    )
  end

  # Order delivered notification
  def order_delivered(order)
    @order = order
    @user = order.user
    @order_items = order.order_items.includes(product_variant: { product: [:brand, :category] })
    
    mail(
      to: @user.email,
      subject: "Your Order #{order.order_number} has been Delivered!",
      from: "#{Rails.application.config.mailer_from_name || 'LuxeThreads'} <#{Rails.application.config.mailer_from_email || 'noreply@luxethreads.com'}>"
    )
  end

  # Order cancelled notification
  def order_cancelled(order)
    @order = order
    @user = order.user
    @cancellation_reason = order.cancellation_reason
    
    mail(
      to: @user.email,
      subject: "Order #{order.order_number} Cancelled",
      from: "#{Rails.application.config.mailer_from_name || 'LuxeThreads'} <#{Rails.application.config.mailer_from_email || 'noreply@luxethreads.com'}>"
    )
  end
end

