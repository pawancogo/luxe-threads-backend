# frozen_string_literal: true

# Serializer for User API responses
class UserSerializer < BaseSerializer
  attributes :id, :first_name, :last_name, :full_name, :email, :phone_number,
             :role, :email_verified, :created_at, :updated_at

  def email_verified
    object.email_verified?
  end
end
