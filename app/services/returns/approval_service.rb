# frozen_string_literal: true

# Service for approving return requests
module Returns
  class ApprovalService < BaseService
    attr_reader :return_request

    def initialize(return_request, admin)
      super()
      @return_request = return_request
      @admin = admin
    end

    def call
      validate_status!
      approve_return
      update_status_history
      set_result(@return_request)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate_status!
      # Can approve from requested or pickup_scheduled status
      unless ['requested', 'pickup_scheduled'].include?(@return_request.status)
        add_error('Return request cannot be approved from current status')
        raise StandardError, 'Invalid status for approval'
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

    def update_status_history
      @return_request.update_status_history('approved', 'Return request approved by admin')
    end
  end
end

