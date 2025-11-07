class SupplierAccountUser < ApplicationRecord
  # Include concerns
  include RbacAuthorizable
  
  # Associations
  belongs_to :supplier_profile
  belongs_to :user
  belongs_to :invited_by, class_name: 'User', optional: true
  belongs_to :rbac_role, optional: true
  belongs_to :role_assigned_by, class_name: 'User', optional: true

  # Enums
  enum :role, {
    owner: 'owner',
    admin: 'admin',
    product_manager: 'product_manager',
    order_manager: 'order_manager',
    accountant: 'accountant',
    staff: 'staff'
  }

  enum :status, {
    active: 'active',
    inactive: 'inactive',
    suspended: 'suspended',
    pending_invitation: 'pending_invitation'
  }, default: 'active'

  # Validations
  validates :role, presence: true
  validates :status, presence: true
  validates :user_id, uniqueness: { scope: :supplier_profile_id, message: "is already associated with this supplier profile" }
  validate :only_one_owner_per_supplier
  validate :invitation_token_present_if_pending

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :owners, -> { where(role: 'owner') }
  scope :admins, -> { where(role: 'admin') }
  scope :pending_invitations, -> { where(status: 'pending_invitation') }

  # Callbacks
  before_create :generate_invitation_token, if: -> { status == 'pending_invitation' && invitation_token.blank? }
  after_create :send_invitation_email, if: -> { status == 'pending_invitation' }

  # Helper methods
  def owner?
    role == 'owner'
  end

  def admin?
    role == 'admin' || role == 'owner'
  end

  def can_manage_products?
    can_manage_products || admin?
  end

  def can_manage_orders?
    can_manage_orders || admin?
  end

  def can_view_financials?
    can_view_financials || admin? || role == 'accountant'
  end

  def can_manage_users?
    can_manage_users || admin?
  end

  def can_manage_settings?
    can_manage_settings || admin?
  end

  def can_view_analytics?
    can_view_analytics || admin?
  end

  # Check if invitation is expired
  def invitation_expired?
    return false unless invitation_expires_at.present?
    invitation_expires_at < Time.current
  end

  # Accept invitation
  def accept_invitation!
    return false if status != 'pending_invitation'
    return false if invitation_expired?

    update!(
      status: 'active',
      accepted_at: Time.current,
      invitation_token: nil,
      invitation_expires_at: nil
    )
  end

  # Parse custom permissions JSON
  def custom_permissions_hash
    return {} if custom_permissions.blank?
    JSON.parse(custom_permissions) rescue {}
  end

  # Update custom permissions
  def update_custom_permissions(permissions)
    update_column(:custom_permissions, permissions.to_json)
  end

  # Suspend user from supplier account
  def suspend!
    update!(status: 'suspended')
  end

  # Activate user
  def activate!
    update!(status: 'active')
  end

  # Update last active timestamp
  def update_last_active!
    update_column(:last_active_at, Time.current)
  end

  private

  def only_one_owner_per_supplier
    return unless role == 'owner'
    
    existing_owner = SupplierAccountUser
      .where(supplier_profile_id: supplier_profile_id, role: 'owner')
      .where.not(id: id)
    
    if existing_owner.exists?
      errors.add(:role, "can only have one owner per supplier profile")
    end
  end

  def invitation_token_present_if_pending
    if status == 'pending_invitation' && invitation_token.blank?
      errors.add(:invitation_token, "is required for pending invitations")
    end
  end

  def generate_invitation_token
    self.invitation_token = SecureRandom.urlsafe_base64(32)
    self.invitation_expires_at = 7.days.from_now
  end

  def send_invitation_email
    # TODO: Implement invitation email service
    # SupplierInvitationMailer.invite_user(self).deliver_now
  end
end


