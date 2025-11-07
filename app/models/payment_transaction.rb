# frozen_string_literal: true

class PaymentTransaction < ApplicationRecord
  belongs_to :payment, optional: true
  belongs_to :order, optional: true
  
  # Transaction types
  enum transaction_type: {
    payment: 'payment',
    refund: 'refund',
    payout: 'payout',
    adjustment: 'adjustment'
  }
  
  # Status
  enum status: {
    pending: 'pending',
    processing: 'processing',
    completed: 'completed',
    failed: 'failed'
  }
  
  validates :transaction_id, presence: true, uniqueness: true
  validates :transaction_type, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true
  
  # Generate unique transaction_id
  before_validation :generate_transaction_id, on: :create
  
  # Parse gateway_response JSON
  def gateway_response_data
    return {} if gateway_response.blank?
    JSON.parse(gateway_response) rescue {}
  end
  
  def gateway_response_data=(data)
    self.gateway_response = data.to_json
  end
  
  private
  
  def generate_transaction_id
    return if transaction_id.present?
    self.transaction_id = "TXN-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
  end
end


