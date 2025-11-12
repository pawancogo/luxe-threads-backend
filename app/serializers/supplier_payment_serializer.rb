# frozen_string_literal: true

# Serializer for SupplierPayment API responses
class SupplierPaymentSerializer < BaseSerializer
  attributes :id, :payment_id, :supplier_profile_id, :amount, :net_amount,
             :currency, :payment_method, :status, :period_start_date,
             :period_end_date, :created_at, :processed_at, :commission_deducted,
             :commission_rate, :notes, :bank_account_details, :transaction_reference,
             :failure_reason, :processed_by, :supplier_profile

  def amount
    object.amount.to_f
  end

  def net_amount
    object.net_amount.to_f
  end

  def period_start_date
    object.period_start_date&.iso8601
  end

  def period_end_date
    object.period_end_date&.iso8601
  end

  def created_at
    object.created_at&.iso8601
  end

  def processed_at
    object.processed_at&.iso8601
  end

  def commission_deducted
    object.commission_deducted.to_f
  end

  def commission_rate
    object.commission_rate
  end

  def notes
    object.notes
  end

  def bank_account_details
    object.bank_account_details_data
  end

  def processed_by
    return nil unless object.processed_by
    
    {
      id: object.processed_by.id,
      name: object.processed_by.full_name || object.processed_by.email
    }
  end

  def supplier_profile
    {
      id: object.supplier_profile.id,
      company_name: object.supplier_profile.company_name
    }
  end
end

