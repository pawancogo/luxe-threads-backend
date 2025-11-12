# frozen_string_literal: true

# Concern for models that need email verification
# Extracts verification logic from models
module Verifiable
  extend ActiveSupport::Concern

  included do
    has_many :email_verifications, as: :verifiable, dependent: :destroy
  end

  # Delegate to EmailVerificationService
  def send_verification_email
    EmailVerificationService.new(self).send_verification_email
  end

  def resend_verification_email
    EmailVerificationService.new(self).resend_verification_email
  end

  def verify_email_with_token(token)
    EmailVerificationService.new(self).verify_email_with_token(token)
  end

  def verification_status
    EmailVerificationService.new(self).verification_status
  end
end

