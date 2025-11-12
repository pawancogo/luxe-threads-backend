# Admin model class
# Note: Admin is also a module (for controller namespacing) defined in config/initializers/admin_namespace.rb
# We use ::Admin in controllers to reference this class when inside the Admin module namespace
class Admin < ApplicationRecord
  extend SearchManager
  
  # Include concerns for shared behavior
  include Passwordable
  include Verifiable
  include Auditable
  include RbacAuthorizable

  # Search manager configuration
  search_manager on: [:email, :first_name, :last_name], aggs_on: [:role, :is_active, :is_blocked]

  # Define admin roles using an enum
  enum :role, {
    super_admin: 'super_admin',
    product_admin: 'product_admin',
    order_admin: 'order_admin',
    user_admin: 'user_admin',
    supplier_admin: 'supplier_admin'
  }

  # Associations
  belongs_to :invited_by, class_name: 'Admin', foreign_key: 'invited_by_id', optional: true
  has_many :invited_admins, class_name: 'Admin', foreign_key: 'invited_by_id', dependent: :nullify
  has_many :created_system_configurations, class_name: 'SystemConfiguration', as: :created_by, dependent: :nullify

  # Validations
  validates :first_name, presence: true, unless: :pending_invitation?
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone_number, presence: true, uniqueness: true, unless: :pending_invitation?
  validates :role, presence: true
  validate :password_requirements, if: :password_required?
  
  # Invitation status enum
  attribute :invitation_status, :string
  enum invitation_status: {
    pending: 'pending',
    accepted: 'accepted',
    expired: 'expired',
    cancelled: 'cancelled'
  }, _prefix: :invitation

  # Callbacks
  # Note: after_create :send_verification_email removed - handled by Admins::CreationService
  after_create :assign_rbac_role_from_enum, if: -> { role.present? }
  after_update :sync_rbac_role_from_enum, if: -> { saved_change_to_role? && role.present? }

  # Helper methods for role checking
  def can_manage_products?
    super_admin? || product_admin?
  end

  def can_manage_orders?
    super_admin? || order_admin?
  end

  def can_manage_users?
    super_admin? || user_admin?
  end

  def can_manage_suppliers?
    super_admin? || supplier_admin?
  end

  # Phase 4: Enhanced admin features
  has_many :admin_activities, dependent: :destroy
  
  # RBAC: Role-based access control
  has_many :admin_role_assignments, dependent: :destroy
  has_many :rbac_roles, through: :admin_role_assignments
  
  # Parse permissions JSON
  def permissions_hash
    return {} if permissions.blank?
    JSON.parse(permissions) rescue {}
  end
  
  def permissions_hash=(hash)
    self.permissions = hash.to_json
  end
  
  # Check permission (delegates to RbacAuthorizable concern)
  # This method is kept for backward compatibility
  def has_permission?(permission)
    super # Uses RbacAuthorizable concern
  end
  
  # Update last login timestamp
  # NOTE: Using update_column for timestamp tracking only (no validations/callbacks needed)
  # This is acceptable for performance-critical timestamp updates
  def update_last_login!
    update_column(:last_login_at, Time.current)
  end
  
  # Note: block! and unblock! methods removed - use Admins::BlockService and Admins::UnblockService instead

  def full_name
    if first_name.present? && last_name.present?
      "#{first_name} #{last_name}"
    elsif first_name.present?
      first_name
    elsif email.present?
      email.split('@').first.humanize
    else
      "Admin ##{id}"
    end
  end

  # Verification methods inherited from Verifiable concern

  # Business logic methods - delegate to services
  # Note: Email sending is handled by services (EmailVerificationService, PasswordResetService)
  
  def authenticate_with_temp_password(temp_password)
    Authentication::TempPasswordService.authenticate_temp_password(self, temp_password)
  end

  # Deprecated: Use PasswordResetCompletionService instead
  def reset_password_with_temp_password(temp_password, new_password)
    service = Authentication::PasswordResetCompletionService.new(self, temp_password, new_password)
    service.call
    service.success?
  end

  def temp_password_expired?
    Authentication::TempPasswordService.temp_password_expired?(self)
  end

  # Password authentication methods
  def authenticate(password)
    return false if password_digest.blank?
    Authentication::PasswordHashingService.verify_password(password, password_digest)
  end

  def password=(new_password)
    @password = new_password
    self.password_digest = Authentication::PasswordHashingService.hash_password(new_password) if new_password.present?
  end

  # Invitation methods (public for use in views)
  def pending_invitation?
    invitation_status == 'pending' && invitation_token.present?
  end

  def invitation_expired?
    invitation_expires_at.present? && invitation_expires_at < Time.current
  end

  def can_accept_invitation?
    pending_invitation? && !invitation_expired?
  end

  private

  def password_requirements
    return unless password.present?
    
    errors = Authentication::PasswordValidationService.errors(password)
    errors.each { |error| self.errors.add(:password, error) }
  end

  def password_required?
    password.present? && !password_reset_required?
  end

  def send_verification_email
    Authentication::EmailVerificationService.new(self).send_verification_email
  end
  
  # Automatically assign RBAC role based on enum role
  def assign_rbac_role_from_enum
    return unless defined?(Rbac::RoleService)
    
    role_slug = Rbac::RoleService.map_legacy_admin_role(role)
    return unless role_slug
    
    # Check if role assignment already exists
    rbac_role = RbacRole.find_by(slug: role_slug)
    return unless rbac_role
    
    existing_assignment = AdminRoleAssignment.find_by(admin: self, rbac_role: rbac_role)
    return if existing_assignment&.active?
    
    Rbac::RoleService.assign_role_to_admin(
      admin: self,
      role_slug: role_slug,
      assigned_by: self
    )
  rescue => e
    Rails.logger.warn "Failed to assign RBAC role to admin #{id}: #{e.message}"
    # Don't fail admin creation if RBAC assignment fails
  end
  
  # Sync RBAC role when enum role changes
  def sync_rbac_role_from_enum
    return unless defined?(Rbac::RoleService)
    
    # Deactivate old role assignments
    admin_role_assignments.current.update_all(is_active: false)
    
    # Assign new role
    assign_rbac_role_from_enum
  rescue => e
    Rails.logger.warn "Failed to sync RBAC role for admin #{id}: #{e.message}"
  end
end
