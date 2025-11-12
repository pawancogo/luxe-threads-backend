# frozen_string_literal: true

# Service for suppliers to respond to reviews
module Reviews
  class SupplierResponseService < BaseService
    attr_reader :review

    def initialize(review, supplier_profile, supplier_response)
      super()
      @review = review
      @supplier_profile = supplier_profile
      @supplier_response = supplier_response
    end

    def call
      validate_supplier_access!
      validate_response!
      add_response
      set_result(@review)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate_supplier_access!
      unless @review.product.supplier_profile_id == @supplier_profile.id
        add_error('Not authorized to respond to this review')
        raise StandardError, 'Access denied'
      end
    end

    def validate_response!
      if @supplier_response.blank?
        add_error('Supplier response is required')
        raise StandardError, 'Response required'
      end
    end

    def add_response
      unless @review.update(
        supplier_response: @supplier_response,
        supplier_response_at: Time.current
      )
        add_errors(@review.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @review
      end
    end
  end
end

