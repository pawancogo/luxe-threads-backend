# frozen_string_literal: true

# Service for resolving support tickets
module Support
  class ResolutionService < BaseService
    attr_reader :support_ticket

    def initialize(support_ticket, resolver, resolution_notes)
      super()
      @support_ticket = support_ticket
      @resolver = resolver
      @resolution_notes = resolution_notes
    end

    def call
      with_transaction do
        resolve_ticket
      end
      set_result(@support_ticket)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def resolve_ticket
      unless @support_ticket.update(
        resolved_by: @resolver,
        resolved_at: Time.current,
        resolution: @resolution_notes,
        status: 'resolved'
      )
        add_errors(@support_ticket.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @support_ticket
      end
    end
  end
end

