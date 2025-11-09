# frozen_string_literal: true

# Concern for models that need password authentication
# Extracts password hashing and validation logic
module Passwordable
  extend ActiveSupport::Concern

  included do
    attr_accessor :password, :password_confirmation
    validates :password, presence: true, on: :create, unless: :pending_invitation?
    validates :password, length: { minimum: 8 }, if: :password_required?
    validates :password_confirmation, presence: true, if: -> { password.present? && (new_record? || password_required?) }
    validate :password_confirmation_match, if: -> { password.present? }
  end

  # Set password with automatic hashing
  def password=(new_password)
    @password = new_password
    self.password_digest = PasswordHashingService.hash_password(new_password) if new_password.present?
  end

  # Authenticate with password
  def authenticate(password)
    return false if password_digest.blank?
    PasswordHashingService.verify_password(password, password_digest)
  end

  private

  def password_required?
    password.present? && !password_reset_required?
  end

  def password_confirmation_match
    return if password.blank? || password_confirmation.blank?
    
    if password != password_confirmation
      errors.add(:password_confirmation, "doesn't match password")
    end
  end
end

