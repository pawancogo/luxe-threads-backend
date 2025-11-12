# frozen_string_literal: true

# Service for deactivating admins
module Admins
  class DeactivationService < BaseService
    attr_reader :admin

    def initialize(admin)
      super()
      @admin = admin
    end

    def call
      with_transaction do
        deactivate_admin
        send_verification_email
      end
      set_result(@admin)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def deactivate_admin
      unless @admin.update(is_active: false, email_verified: false)
        add_errors(@admin.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @admin
      end
    end

    def send_verification_email
      # Always send verification email to require re-verification for reactivation
      unless @admin.email_verifications.pending.active.exists?
        Authentication::EmailVerificationService.new(@admin).send_verification_email
      end
    end
  end
end

