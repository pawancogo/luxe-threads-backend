# frozen_string_literal: true

# Service for adding notes to orders
module Orders
  class NoteAdditionService < BaseService
    attr_reader :order

    def initialize(order, note, admin)
      super()
      @order = order
      @note = note
      @admin = admin
    end

    def call
      validate_note!
      add_note
      set_result(@order)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate_note!
      unless @note.present?
        add_error('Note is required')
        raise StandardError, 'Note is required'
      end
    end

    def add_note
      timestamp = Time.current.strftime('%Y-%m-%d %H:%M:%S')
      admin_name = @admin.full_name
      new_note = "\n[#{timestamp}] #{admin_name}: #{@note}"
      
      current_notes = @order.internal_notes || ''
      unless @order.update(internal_notes: current_notes + new_note)
        add_errors(@order.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @order
      end
    end
  end
end

