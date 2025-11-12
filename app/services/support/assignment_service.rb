# frozen_string_literal: true

# Service for assigning support tickets to admins
module Support
  class AssignmentService < BaseService
    attr_reader :support_ticket

    def initialize(support_ticket, admin)
      super()
      @support_ticket = support_ticket
      @admin = admin
    end

    def call
      with_transaction do
        assign_ticket
      end
      set_result(@support_ticket)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def assign_ticket
      unless @support_ticket.update(assigned_to: @admin, assigned_at: Time.current, status: 'in_progress')
        add_errors(@support_ticket.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @support_ticket
      end
    end
  end
end

