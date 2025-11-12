# frozen_string_literal: true

# Service for closing support tickets
module Support
  class ClosureService < BaseService
    attr_reader :support_ticket

    def initialize(support_ticket)
      super()
      @support_ticket = support_ticket
    end

    def call
      with_transaction do
        close_ticket
      end
      set_result(@support_ticket)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def close_ticket
      unless @support_ticket.update(status: 'closed', closed_at: Time.current)
        add_errors(@support_ticket.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @support_ticket
      end
    end
  end
end

