# frozen_string_literal: true

class SupplierPayment < ApplicationRecord
  belongs_to :supplier_profile
  belongs_to :processed_by, class_name: 'Admin', optional: true
  
  # Payment methods
  enum payment_method: {
    bank_transfer: 'bank_transfer',
    upi: 'upi',
    neft: 'neft',
    rtgs: 'rtgs'
  }
  
  # Status
  enum status: {
    pending: 'pending',
    processing: 'processing',
    completed: 'completed',
    failed: 'failed',
    cancelled: 'cancelled'
  }
  
  validates :payment_id, presence: true, uniqueness: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :net_amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :payment_method, presence: true
  validates :period_start_date, presence: true
  validates :period_end_date, presence: true
  
  # Generate unique payment_id
  before_validation :generate_payment_id, on: :create
  
  # Calculate net_amount
  before_validation :calculate_net_amount, on: :create
  
  # Helper methods for API responses
  def bank_account_details_data
    return nil unless bank_account_number.present? || bank_ifsc_code.present?
    {
      account_holder_name: supplier_profile.account_holder_name,
      bank_account_number: bank_account_number,
      ifsc_code: bank_ifsc_code,
      bank_branch: supplier_profile.bank_branch,
      upi_id: supplier_profile.upi_id
    }
  end

  def commission_rate
    return nil if amount.blank? || commission_deducted.blank? || amount.zero?
    ((commission_deducted / amount) * 100).round(2)
  end

  def notes
    # Notes field doesn't exist in schema, but we can use failure_reason or add a notes field later
    failure_reason
  end
  
  private
  
  def generate_payment_id
    return if payment_id.present?
    self.payment_id = "SUP-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
  end
  
  def calculate_net_amount
    return if amount.blank? || commission_deducted.blank?
    self.net_amount = amount - commission_deducted
  end
end


