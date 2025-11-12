# frozen_string_literal: true

# Service for resetting password using temporary password
module Authentication
  class PasswordResetCompletionService < BaseService
    attr_reader :user

    def initialize(user, temp_password, new_password)
      super()
      @user = user
      @temp_password = temp_password
      @new_password = new_password
    end

    def call
      validate_temp_password!
      validate_new_password!
      reset_password
      clear_temp_password
      set_result(@user)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate_temp_password!
      unless Authentication::TempPasswordService.authenticate_temp_password(@user, @temp_password)
        add_error('Invalid temporary password')
        raise StandardError, 'Invalid temporary password'
      end

      if Authentication::TempPasswordService.temp_password_expired?(@user)
        add_error('Temporary password has expired')
        raise StandardError, 'Temporary password has expired'
      end
    end

    def validate_new_password!
      unless Authentication::PasswordValidationService.valid?(@new_password)
        errors = Authentication::PasswordValidationService.errors(@new_password)
        add_errors(errors)
        raise StandardError, 'Password validation failed'
      end
    end

    def reset_password
      @user.update!(password: @new_password)
    end

    def clear_temp_password
      Authentication::TempPasswordService.clear_temp_password(@user)
    end
  end
end

