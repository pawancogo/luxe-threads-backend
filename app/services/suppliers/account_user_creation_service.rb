# frozen_string_literal: true

# Service for creating supplier account user (owner)
# Extracted from UserCreationService for Single Responsibility
module Suppliers
  class AccountUserCreationService < BaseService
    attr_reader :supplier_account_user

    def initialize(supplier_profile, user, role: 'owner')
      super()
      @supplier_profile = supplier_profile
      @user = user
      @role = role
    end

    def call
      return existing_account_user if existing_account_user.present?

      with_transaction do
        create_account_user
        assign_rbac_role if rbac_available?
        set_result(@supplier_account_user)
      end

      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def existing_account_user
      @existing_account_user ||= SupplierAccountUser.find_by(
        supplier_profile: @supplier_profile,
        user: @user
      )
    end

    def create_account_user
      log_execution('create_account_user', {
        supplier_profile_id: @supplier_profile.id,
        user_id: @user.id,
        role: @role
      })

      @supplier_account_user = SupplierAccountUser.find_or_create_by!(
        supplier_profile: @supplier_profile,
        user: @user
      ) do |sau|
        sau.role = @role
        sau.status = 'active'
        set_default_permissions(sau)
        sau.accepted_at = Time.current
      end
    end

    def set_default_permissions(sau)
      # Set default permissions for owner role
      if @role == 'owner'
        sau.can_manage_products = true
        sau.can_manage_orders = true
        sau.can_view_financials = true
        sau.can_manage_users = true
        sau.can_manage_settings = true
        sau.can_view_analytics = true
      end
    end

    def assign_rbac_role
      return unless defined?(Rbac::RoleService)

      role_slug = Rbac::RoleService.map_legacy_supplier_role(@role)
      Rbac::RoleService.assign_role_to_supplier_user(
        supplier_account_user: @supplier_account_user,
        role_slug: role_slug,
        assigned_by: @user
      )
    rescue => e
      # Log but don't fail if RBAC assignment fails
      Rails.logger.warn "Failed to assign RBAC role: #{e.message}"
    end

    def rbac_available?
      defined?(Rbac::RoleService)
    end
  end
end

