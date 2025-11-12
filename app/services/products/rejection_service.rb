# frozen_string_literal: true

# Service for rejecting products
module Products
  class RejectionService < BaseService
    attr_reader :product

    def initialize(product, admin, rejection_reason: nil)
      super()
      @product = product
      @admin = admin
      @rejection_reason = rejection_reason
    end

    def call
      validate!
      reject_product
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

    def reject_product
      update_attributes = {
        status: 'rejected',
        verified_by_admin_id: @admin.id,
        verified_at: Time.current
      }
      update_attributes[:rejection_reason] = @rejection_reason if @rejection_reason.present?
      
      unless @product.update(update_attributes)
        add_errors(@product.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @product
      end
    end
  end
end

