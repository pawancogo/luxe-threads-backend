# frozen_string_literal: true

# Service for updating user passwords
module Users
  class PasswordUpdateService < BaseService
    attr_reader :user

    def initialize(user, current_password, new_password, password_confirmation)
      super()
      @user = user
      @current_password = current_password
      @new_password = new_password
      @password_confirmation = password_confirmation
    end

    def call
      validate_current_password!
      update_password
      set_result(@user)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate_current_password!
      unless @user.authenticate(@current_password)
        add_error('Current password is incorrect')
        raise StandardError, 'Current password is incorrect'
      end
    end

    def update_password
      unless @user.update(password: @new_password, password_confirmation: @password_confirmation)
        add_errors(@user.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @user
      end
    end
  end
end

