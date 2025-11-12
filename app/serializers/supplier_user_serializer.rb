# frozen_string_literal: true

# Serializer for Supplier User API responses
class SupplierUserSerializer < BaseSerializer
  attributes :id, :email, :first_name, :last_name, :full_name, :phone_number,
             :role, :status, :permissions, :invited_at, :accepted_at,
             :invitation_status

  def role
    account_user&.role
  end

  def status
    account_user&.status
  end

  def permissions
    return {} unless account_user
    
    {
      can_manage_products: account_user.can_manage_products,
      can_manage_orders: account_user.can_manage_orders,
      can_view_financials: account_user.can_view_financials,
      can_manage_users: account_user.can_manage_users,
      can_manage_settings: account_user.can_manage_settings,
      can_view_analytics: account_user.can_view_analytics
    }
  end

  def invited_at
    account_user&.created_at
  end

  def accepted_at
    account_user&.accepted_at
  end

  def invitation_status
    object.invitation_status
  end

  private

  def account_user
    @account_user ||= object.supplier_account_users.find_by(supplier_profile: options[:supplier_profile])
  end
end

