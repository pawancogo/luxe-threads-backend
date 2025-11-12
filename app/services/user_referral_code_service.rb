# frozen_string_literal: true

# Service for generating and managing user referral codes
# Extracted from User model to follow Single Responsibility Principle
class UserReferralCodeService < BaseService
  attr_reader :referral_code

  def initialize(user)
    super()
    @user = user
  end

  def call
    return set_result(@user.referral_code) if @user.referral_code.present?

    generate_code
    set_result(@referral_code)
    self
  rescue StandardError => e
    handle_error(e)
    self
  end

  private

  def generate_code
    code = SecureRandom.alphanumeric(8).upcase
    while User.exists?(referral_code: code)
      code = SecureRandom.alphanumeric(8).upcase
    end
    # Use update! to trigger validations and callbacks
    @user.update!(referral_code: code)
    @referral_code = code
  end
end

