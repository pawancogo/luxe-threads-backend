# frozen_string_literal: true

# Service for sending order-related emails
# Extracted from Order model callbacks to follow SRP
module Orders
  class EmailService
    def self.send_confirmation(order)
      EmailDeliveryService.deliver(-> { OrderMailer.order_confirmation(order) })
    rescue StandardError => e
      Rails.logger.error "Failed to send order confirmation email for order #{order.id}: #{e.message}"
      false
    end

    def self.send_status_notification(order)
      case order.status
      when 'shipped'
        send_shipped_notification(order)
      when 'delivered'
        send_delivered_notification(order)
      end
    end

    def self.send_cancellation(order)
      EmailDeliveryService.deliver(-> { OrderMailer.order_cancelled(order) })
    rescue StandardError => e
      Rails.logger.error "Failed to send cancellation email for order #{order.id}: #{e.message}"
      false
    end

    def self.send_shipped_notification(order)
      EmailDeliveryService.deliver(-> { OrderMailer.order_shipped(order) })
    rescue StandardError => e
      Rails.logger.error "Failed to send shipping notification email for order #{order.id}: #{e.message}"
      false
    end

    def self.send_delivered_notification(order)
      EmailDeliveryService.deliver(-> { OrderMailer.order_delivered(order) })
    rescue StandardError => e
      Rails.logger.error "Failed to send delivery notification email for order #{order.id}: #{e.message}"
      false
    end

    private_class_method :send_shipped_notification, :send_delivered_notification
  end
end


