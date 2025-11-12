# frozen_string_literal: true

# Service for activating admins
module Admins
  class ActivationService < BaseService
    attr_reader :admin

    def initialize(admin)
      super()
      @admin = admin
    end

    def call
      with_transaction do
        activate_admin
      end
      set_result(@admin)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def activate_admin
      unless @admin.update(is_active: true)
        add_errors(@admin.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @admin
      end
    end
  end
end

