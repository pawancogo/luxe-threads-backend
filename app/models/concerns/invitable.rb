# frozen_string_literal: true

# Concern for models that can be invited
# Extracts invitation-related logic
module Invitable
  extend ActiveSupport::Concern

  included do
    # Invitation status enum
    attribute :invitation_status, :string
    enum invitation_status: {
      pending: 'pending',
      accepted: 'accepted',
      expired: 'expired',
      cancelled: 'cancelled'
    }, _prefix: :invitation
  end

  # Check if invitation is pending
  def pending_invitation?
    invitation_status == 'pending' && invitation_token.present?
  end

  # Check if invitation has expired
  def invitation_expired?
    invitation_expires_at.present? && invitation_expires_at < Time.current
  end

  # Check if invitation can be accepted
  def can_accept_invitation?
    pending_invitation? && !invitation_expired?
  end

  # Check if invitation has been accepted
  def invitation_accepted?
    invitation_status == 'accepted' && invitation_accepted_at.present?
  end
end

