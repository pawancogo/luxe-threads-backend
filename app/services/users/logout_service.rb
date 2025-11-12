# frozen_string_literal: true

# Service for logging out users
module Users
  class LogoutService < BaseService
    attr_reader :user

    def initialize(user)
      super()
      @user = user
    end

    def call
      return self unless @user

      with_transaction do
        invalidate_sessions
      end

      set_result({})
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def invalidate_sessions
      LoginSession.for_user(@user)
                  .active
                  .where(logged_out_at: nil)
                  .update_all(logged_out_at: Time.current, is_active: false)
    end
  end
end

