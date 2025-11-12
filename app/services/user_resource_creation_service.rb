# frozen_string_literal: true

# Service for creating user-associated resources
# Follows Single Responsibility - only creates resources, not the user itself
class UserResourceCreationService < BaseService
  def initialize(user, options = {})
    super()
    @user = user
    @options = options
  end

  def call
    return self unless @user.persisted?

    with_transaction do
      create_cart
      create_wishlist
      create_supplier_resources if supplier_user?
      send_verification_email
    end

    set_result(true)
    self
  rescue StandardError => e
    handle_error(e)
    self
  end

  private

  def create_cart
    Carts::CreationService.new(@user).call
  end

  def create_wishlist
    Wishlists::CreationService.new(@user).call
  end

  def create_supplier_resources
    create_supplier_profile
    create_supplier_account_user if @user.supplier_profile.present?
  end

  def create_supplier_profile
    service = Suppliers::ProfileCreationService.new(@user, @options)
    service.call
    
    if service.profile.nil?
      add_error('Failed to create supplier profile')
      set_last_error(StandardError.new('Suppliers::ProfileCreationService returned nil'))
    else
      @user.reload
    end
  rescue StandardError => e
    add_error("Failed to create supplier profile: #{e.message}")
    set_last_error(e)
  end

  def create_supplier_account_user
    return unless @user.supplier_profile.present?

    # Ensure owner_id is set
    profile = @user.supplier_profile
    profile.update!(owner_id: @user.id, user_id: @user.id) if profile.owner_id.blank?

    service = Suppliers::AccountUserCreationService.new(profile, @user, role: 'owner')
    service.call

    unless service.success?
      add_errors(service.errors)
      set_last_error(service.last_error) if service.last_error
    end
  rescue StandardError => e
    add_error("Failed to create supplier account user: #{e.message}")
    set_last_error(e)
  end

  def send_verification_email
    Authentication::EmailVerificationService.new(@user).send_verification_email
  rescue StandardError => e
    # Don't fail user creation if email fails
    Rails.logger.warn "Failed to send verification email: #{e.message}"
  end

  def supplier_user?
    @user.role == 'supplier'
  end
end

