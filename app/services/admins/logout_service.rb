# frozen_string_literal: true

# Service for logging out admins
module Admins
  class LogoutService < BaseService
    attr_reader :admin

    def initialize(admin, request, session_token: nil)
      super()
      @admin = admin
      @request = request
      @session_token = session_token
    end

    def call
      return self unless @admin

      with_transaction do
        invalidate_sessions
        log_activity
      end

      set_result({})
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def invalidate_sessions
      scope = LoginSession.for_user(@admin)
                          .active
                          .where(logged_out_at: nil)

      # If session_token provided, filter by it
      if @session_token.present?
        scope = scope.where("session_token LIKE ?", "#{@session_token}%")
      end

      scope.update_all(logged_out_at: Time.current, is_active: false)
    end

    def log_activity
      AdminActivity.log_activity(
        @admin,
        'logout',
        nil,
        nil,
        {
          description: 'Admin logged out',
          ip_address: @request.remote_ip,
          user_agent: @request.user_agent
        }
      )
    end
  end
end

