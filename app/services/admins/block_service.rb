# frozen_string_literal: true

# Service for blocking an admin
module Admins
  class BlockService < BaseService
    attr_reader :admin

    def initialize(admin)
      super()
      @admin = admin
    end

    def call
      with_transaction do
        block_admin
        invalidate_sessions
      end
      set_result(@admin)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def block_admin
      unless @admin.update(is_blocked: true, is_active: false)
        add_errors(@admin.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @admin
      end
    end

    def invalidate_sessions
      # Invalidate all active login sessions for this admin
      LoginSession.for_user(@admin)
                  .active
                  .where(logged_out_at: nil)
                  .update_all(
                    logged_out_at: Time.current,
                    is_active: false
                  )
    end
  end
end

