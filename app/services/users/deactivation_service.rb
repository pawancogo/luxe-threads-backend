# frozen_string_literal: true

# Service for deactivating users
module Users
  class DeactivationService < BaseService
    attr_reader :user

    def initialize(user)
      super()
      @user = user
    end

    def call
      with_transaction do
        deactivate_user
        send_verification_email
      end
      set_result(@user)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def deactivate_user
      unless @user.update(is_active: false, deleted_at: Time.current)
        add_errors(@user.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @user
      end
    end

    def send_verification_email
      # Send verification email to user so they can reactivate their account
      unless @user.email_verifications.pending.active.exists?
        Authentication::EmailVerificationService.new(@user).send_verification_email
      end
    end
  end
end

