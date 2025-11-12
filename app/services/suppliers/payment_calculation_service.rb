# frozen_string_literal: true

# Service for calculating supplier payment net amount
# Extracted from SupplierPayment model to follow SOLID principles
module Suppliers
  class PaymentCalculationService < BaseService
    attr_reader :net_amount

    def initialize(amount, commission_deducted)
      super()
      @amount = amount.to_f
      @commission_deducted = commission_deducted.to_f
    end

    def call
      validate_inputs!
      calculate_net_amount
      set_result(@net_amount)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate_inputs!
      if @amount.blank? || @amount <= 0
        add_error('Amount must be greater than 0')
        raise StandardError, 'Invalid amount'
      end
    end

    def calculate_net_amount
      @net_amount = @amount - @commission_deducted
      @net_amount = 0.0 if @net_amount < 0
    end
  end
end

