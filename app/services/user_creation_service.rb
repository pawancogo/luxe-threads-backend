# frozen_string_literal: true

# Service for creating users with all associated resources
# Replaces after_create callbacks with explicit service calls
class UserCreationService
  attr_reader :user, :errors

  def initialize(user_params)
    @user_params = user_params
    @errors = []
  end

  def call
    ActiveRecord::Base.transaction do
      create_user
      create_associated_resources if @user.persisted?
    end

    @user
  rescue StandardError => e
    @errors << e.message
    Rails.logger.error "UserCreationService failed: #{e.message}"
    @user ||= build_user
    @user
  end

  def success?
    @user&.persisted? && @errors.empty?
  end

  private

  def create_user
    @user = User.new(@user_params)
    unless @user.save
      @errors.concat(@user.errors.full_messages)
      raise ActiveRecord::RecordInvalid, @user
    end
  end

  def create_associated_resources
    CartCreationService.new(@user).call
    WishlistCreationService.new(@user).call
    SupplierProfileCreationService.new(@user).call if supplier_user?
    EmailVerificationService.new(@user).send_verification_email
  end

  def build_user
    User.new(@user_params)
  end

  def supplier_user?
    @user_params[:role] == 'supplier' || @user.role == 'supplier'
  end
end

