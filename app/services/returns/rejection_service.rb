# frozen_string_literal: true

# Service for rejecting return requests
module Returns
  class RejectionService < BaseService
    attr_reader :return_request

    def initialize(return_request, rejection_reason, admin)
      super()
      @return_request = return_request
      @rejection_reason = rejection_reason || 'Return request rejected'
      @admin = admin
    end

    def call
      validate_status!
      reject_return
      update_status_history
      set_result(@return_request)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate_status!
      # Can reject from requested or pickup_scheduled status
      unless ['requested', 'pickup_scheduled'].include?(@return_request.status)
        add_error('Return request cannot be rejected from current status')
        raise StandardError, 'Invalid status for rejection'
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
      @return_request.update_status_history('rejected', @rejection_reason)
    end
  end
end

