# frozen_string_literal: true

# Service for handling password reset requests
# Generates temp password and sends reset email
module Authentication
  class PasswordResetService < BaseService
    attr_reader :user

    def initialize(user, user_type: 'user')
      super()
      @user = user
      @user_type = user_type
    end

    def call
      return self unless @user

      generate_temp_password
      send_reset_email
      set_result(@user)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def generate_temp_password
      result = Authentication::TempPasswordService.generate_for(@user)
      @temp_password = result[:temp_password]
      @reset_token = result[:token]
    end

    def send_reset_email
      VerificationMailer.password_reset_email(
        @user,
        @temp_password,
        @reset_token,
        @user_type
      ).deliver_now
    end
  end
end

