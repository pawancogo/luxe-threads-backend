# frozen_string_literal: true

# Service for suppliers to approve return requests
module Suppliers
  class ReturnApprovalService < BaseService
    attr_reader :return_request

    def initialize(return_request, supplier_profile, notes: nil)
      super()
      @return_request = return_request
      @supplier_profile = supplier_profile
      @notes = notes
    end

    def call
      validate_supplier_access!
      validate_status!
      approve_return
      update_order_items
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
        add_error('Return request can only be approved when status is requested')
        raise StandardError, 'Invalid return status'
      end
    end

    def approve_return
      unless @return_request.update(
        status: 'approved',
        status_updated_at: Time.current
      )
        add_errors(@return_request.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @return_request
      end
    end

    def update_order_items
      @return_request.return_items.each do |return_item|
        return_item.order_item.update!(return_requested: true)
      end
    end

    def update_status_history
      message = @notes.present? ? "Approved by supplier: #{@notes}" : 'Approved by supplier: No notes provided'
      @return_request.add_status_to_history('approved', message)
    end
  end
end

