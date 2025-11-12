# frozen_string_literal: true

# Service for rejecting suppliers
module Suppliers
  class RejectionService < BaseService
    attr_reader :supplier

    def initialize(supplier, admin: nil)
      super()
      @supplier = supplier
      @admin = admin
    end

    def call
      validate!
      update_verification
      set_result(@supplier)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate!
      profile = @supplier.primary_supplier_profile || @supplier.supplier_profile
      unless profile
        add_error('Supplier profile not found')
        raise StandardError, 'Supplier profile not found'
      end
    end

    def update_verification
      profile = @supplier.primary_supplier_profile || @supplier.supplier_profile
      
      unless profile.update(verified: false)
        add_errors(profile.errors.full_messages)
        raise ActiveRecord::RecordInvalid, profile
      end
    end
  end
end

