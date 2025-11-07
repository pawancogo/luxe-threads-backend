# frozen_string_literal: true

class PaymentRefund < ApplicationRecord
  belongs_to :payment
  belongs_to :order
  belongs_to :order_item, optional: true
  belongs_to :processed_by, class_name: 'User', optional: true
  
  # Status
  enum status: {
    pending: 'pending',
    processing: 'processing',
    completed: 'completed',
    failed: 'failed',
    cancelled: 'cancelled'
  }
  
  validates :refund_id, presence: true, uniqueness: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :reason, presence: true
  
  # Generate unique refund_id
  before_validation :generate_refund_id, on: :create
  
  # Parse gateway_response JSON
  def gateway_response_data
    return {} if gateway_response.blank?
    JSON.parse(gateway_response) rescue {}
  end
  
  def gateway_response_data=(data)
    self.gateway_response = data.to_json
  end
  
  private
  
  def generate_refund_id
    return if refund_id.present?
    self.refund_id = "REF-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
  end
end


