# frozen_string_literal: true

# Service for updating supplier tier
module Suppliers
  class TierUpdateService < BaseService
    attr_reader :supplier

    def initialize(supplier, tier)
      super()
      @supplier = supplier
      @tier = tier
    end

    def call
      validate!
      update_tier
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

      unless @tier.present?
        add_error('Tier is required')
        raise StandardError, 'Tier is required'
      end
    end

    def update_tier
      profile = @supplier.primary_supplier_profile || @supplier.supplier_profile
      
      unless profile.update(supplier_tier: @tier)
        add_errors(profile.errors.full_messages)
        raise ActiveRecord::RecordInvalid, profile
      end
    end
  end
end

