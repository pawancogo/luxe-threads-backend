# frozen_string_literal: true

# Service for updating supplier status
module Suppliers
  class StatusUpdateService < BaseService
    attr_reader :supplier

    def initialize(supplier, status, suspension_reason: nil, admin: nil)
      super()
      @supplier = supplier
      @status = status
      @suspension_reason = suspension_reason
      @admin = admin
    end

    def call
      validate!
      update_status
      set_result(@supplier)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate!
      unless %w[active inactive suspended].include?(@status.to_s)
        add_error('Invalid status')
        raise StandardError, 'Invalid status'
      end
    end

    def update_status
      case @status.to_s
      when 'active'
        activate_supplier
      when 'inactive'
        deactivate_supplier
      when 'suspended'
        suspend_supplier
      end
    end

    def activate_supplier
      @supplier.update(deleted_at: nil)
      profile = @supplier.primary_supplier_profile || @supplier.supplier_profile
      profile&.update(is_suspended: false, is_active: true)
    end

    def deactivate_supplier
      @supplier.update(deleted_at: Time.current)
    end

    def suspend_supplier
      profile = @supplier.primary_supplier_profile || @supplier.supplier_profile
      
      unless profile
        add_error('Supplier profile not found')
        raise StandardError, 'Supplier profile not found'
      end
      
      reason = @suspension_reason || 'Supplier account suspended by admin'
      
      if profile.suspend!(reason) && @supplier.update(deleted_at: Time.current)
        # Success
      else
        add_error('Failed to suspend supplier')
        raise StandardError, 'Failed to suspend supplier'
      end
    end
  end
end

