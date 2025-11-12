# frozen_string_literal: true

# Service for bulk approving products
module Products
  class BulkApprovalService < BaseService
    attr_reader :products

    def initialize(product_ids, admin)
      super()
      @product_ids = Array(product_ids)
      @admin = admin
    end

    def call
      validate!
      approve_products
      set_result(@products)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate!
      if @product_ids.empty?
        add_error('No products selected')
        raise StandardError, 'No products selected'
      end

      unless @admin
        add_error('Admin is required')
        raise StandardError, 'Admin is required'
      end
    end

    def approve_products
      @products = Product.where(id: @product_ids)
      @products.update_all(
        status: 'active',
        verified_by_admin_id: @admin.id,
        verified_at: Time.current,
        rejection_reason: nil
      )
      @products = Product.where(id: @product_ids) # Reload to get updated records
    end
  end
end

