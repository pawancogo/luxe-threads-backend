# frozen_string_literal: true

# Service for suppliers to reject return requests
module Suppliers
  class ReturnRejectionService < BaseService
    attr_reader :return_request

    def initialize(return_request, supplier_profile, rejection_reason)
      super()
      @return_request = return_request
      @supplier_profile = supplier_profile
      @rejection_reason = rejection_reason
    end

    def call
      validate_supplier_access!
      validate_status!
      validate_rejection_reason!
      reject_return
      update_status_history
      set_result(@return_request)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate_supplier_access!
      return_item_supplier_ids = @return_request.return_items.joins(:order_item)
                                                .pluck('order_items.supplier_profile_id')
      
      unless return_item_supplier_ids.include?(@supplier_profile.id)
        add_error('Return request does not belong to this supplier')
        raise StandardError, 'Access denied'
      end
    end

    def validate_status!
      unless @return_request.status == 'requested'
        add_error('Return request can only be rejected when status is requested')
        raise StandardError, 'Invalid return status'
      end
    end

    def validate_rejection_reason!
      if @rejection_reason.blank?
        add_error('Rejection reason is required')
        raise StandardError, 'Rejection reason required'
      end
    end

    def reject_return
      unless @return_request.update(
        status: 'rejected',
        status_updated_at: Time.current
      )
        add_errors(@return_request.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @return_request
      end
    end

    def update_status_history
      @return_request.add_status_to_history('rejected', "Rejected by supplier: #{@rejection_reason}")
    end
  end
end

