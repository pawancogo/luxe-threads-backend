# frozen_string_literal: true

# Serializer for admin admin API responses
class AdminAdminSerializer < BaseSerializer
  attributes :id, :email, :first_name, :last_name, :full_name, :phone_number,
             :role, :is_active, :is_blocked, :email_verified, :created_at,
             :updated_at, :last_login_at, :permissions

  def is_active
    object.is_active
  end

  def is_blocked
    object.is_blocked
  end

  def email_verified
    object.email_verified?
  end

  def permissions
    {
      can_manage_products: object.can_manage_products?,
      can_manage_orders: object.can_manage_orders?,
      can_manage_users: object.can_manage_users?,
      can_manage_suppliers: object.can_manage_suppliers?
    }
  end
end

