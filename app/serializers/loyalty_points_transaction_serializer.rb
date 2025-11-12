# frozen_string_literal: true

# Serializer for LoyaltyPointsTransaction API responses
class LoyaltyPointsTransactionSerializer < BaseSerializer
  attributes :id, :transaction_type, :points, :balance_after, :reference_type,
             :reference_id, :description, :expiry_date, :created_at

  def created_at
    format_date(object.created_at)
  end

  def expiry_date
    format_date(object.expiry_date) if object.expiry_date.present?
  end
end

