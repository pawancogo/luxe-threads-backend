# frozen_string_literal: true

# Concern for models that need password authentication
# Extracts password hashing and validation logic
module Passwordable
  extend ActiveSupport::Concern

  included do
    attr_accessor :password
    validates :password, presence: true, on: :create
    validates :password, length: { minimum: 8 }, if: :password_required?
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
end

