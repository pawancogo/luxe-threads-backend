# frozen_string_literal: true

class Payment < ApplicationRecord
  belongs_to :order
  belongs_to :user
  
  has_many :payment_refunds, dependent: :destroy
  has_many :payment_transactions, dependent: :destroy
  
  # Payment methods
  enum payment_method: {
    cod: 'cod',
    credit_card: 'credit_card',
    debit_card: 'debit_card',
    upi: 'upi',
    wallet: 'wallet',
    netbanking: 'netbanking',
    emi: 'emi'
  }
  
  # Status
  enum status: {
    pending: 'pending',
    processing: 'processing',
    completed: 'completed',
    failed: 'failed',
    refunded: 'refunded',
    partially_refunded: 'partially_refunded'
  }
  
  validates :payment_id, presence: true, uniqueness: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :payment_method, presence: true
  
  # Generate unique payment_id
  before_validation :generate_payment_id, on: :create
  
  # Parse gateway_response JSON
  def gateway_response_data
    return {} if gateway_response.blank?
    JSON.parse(gateway_response) rescue {}
  end
  
  def gateway_response_data=(data)
    self.gateway_response = data.to_json
  end
  
  private
  
  def generate_payment_id
    return if payment_id.present?
    self.payment_id = "PAY-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
  end
end


