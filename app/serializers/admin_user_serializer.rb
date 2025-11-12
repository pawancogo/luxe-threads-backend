# frozen_string_literal: true

# Serializer for admin user API responses
class AdminUserSerializer < BaseSerializer
  attributes :id, :email, :first_name, :last_name, :full_name, :phone_number,
             :role, :is_active, :created_at, :orders_count, :addresses,
             :deleted_at, :updated_at

  def is_active
    object.deleted_at.nil?
  end

  def orders_count
    object.orders_count || 0
  end

  def addresses
    object.addresses.map do |address|
      {
        id: address.id,
        street: address.street,
        city: address.city,
        state: address.state,
        zip_code: address.zip_code,
        is_default: address.is_default
      }
    end
  end
end

