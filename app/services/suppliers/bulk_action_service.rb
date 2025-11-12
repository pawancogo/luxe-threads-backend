# frozen_string_literal: true

# Service for bulk supplier actions
module Suppliers
  class BulkActionService < BaseService
    attr_reader :suppliers

    def initialize(supplier_ids, action, admin: nil)
      super()
      @supplier_ids = Array(supplier_ids).reject(&:blank?)
      @action = action
      @admin = admin
    end

    def call
      validate!
      perform_action
      set_result(@suppliers)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate!
      if @supplier_ids.empty?
        add_error('Please select at least one supplier')
        raise StandardError, 'No suppliers selected'
      end

      unless %w[verify unverify delete].include?(@action)
        add_error('Invalid action')
        raise StandardError, 'Invalid action'
      end
    end

    def perform_action
      @suppliers = User.where(id: @supplier_ids, role: 'supplier').includes(:supplier_profile)
      
      case @action
      when 'verify'
        verify_suppliers
      when 'unverify'
        unverify_suppliers
      when 'delete'
        delete_suppliers
      end
    end

    def verify_suppliers
      @suppliers.each do |supplier|
        profile = supplier.primary_supplier_profile || supplier.supplier_profile
        profile&.update(verified: true)
      end
    end

    def unverify_suppliers
      @suppliers.each do |supplier|
        profile = supplier.primary_supplier_profile || supplier.supplier_profile
        profile&.update(verified: false)
      end
    end

    def delete_suppliers
      @suppliers.destroy_all
    end
  end
end

