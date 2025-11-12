# frozen_string_literal: true

# Service for approving products
module Products
  class ApprovalService < BaseService
    attr_reader :product

    def initialize(product, admin)
      super()
      @product = product
      @admin = admin
    end

    def call
      validate!
      approve_product
      set_result(@product)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate!
      unless @admin
        add_error('Admin is required')
        raise StandardError, 'Admin is required'
      end
    end

    def approve_product
      unless @product.update(
        status: 'active',
        verified_by_admin_id: @admin.id,
        verified_at: Time.current,
        rejection_reason: nil
      )
        add_errors(@product.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @product
      end
    end
  end
end

