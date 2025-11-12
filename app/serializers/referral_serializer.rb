# frozen_string_literal: true

# Serializer for Referral API responses
class ReferralSerializer < BaseSerializer
  def serialize
    {
      id: object.id,
      referred_user: serialize_referred_user,
      status: object.status,
      completed_at: format_date(object.completed_at),
      created_at: format_date(object.created_at)
    }
  end

  private

  def serialize_referred_user
    return nil unless object.referred

    {
      id: object.referred.id,
      email: object.referred.email,
      first_name: object.referred.first_name,
      last_name: object.referred.last_name,
      full_name: object.referred.full_name
    }
  end
end


