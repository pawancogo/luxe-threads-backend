# frozen_string_literal: true

# Service for unblocking an admin
module Admins
  class UnblockService < BaseService
    attr_reader :admin

    def initialize(admin)
      super()
      @admin = admin
    end

    def call
      with_transaction do
        unblock_admin
      end
      set_result(@admin)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def unblock_admin
      unless @admin.update(is_blocked: false, is_active: true)
        add_errors(@admin.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @admin
      end
    end
  end
end

