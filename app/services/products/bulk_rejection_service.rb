# frozen_string_literal: true

# Service for bulk rejecting products
module Products
  class BulkRejectionService < BaseService
    attr_reader :products

    def initialize(product_ids, admin, rejection_reason: nil)
      super()
      @product_ids = Array(product_ids)
      @admin = admin
      @rejection_reason = rejection_reason
    end

    def call
      validate!
      reject_products
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

    def reject_products
      update_attributes = {
        status: 'rejected',
        verified_by_admin_id: @admin.id,
        verified_at: Time.current
      }
      update_attributes[:rejection_reason] = @rejection_reason if @rejection_reason.present?
      
      @products = Product.where(id: @product_ids)
      @products.update_all(update_attributes)
      @products = Product.where(id: @product_ids) # Reload to get updated records
    end
  end
end

