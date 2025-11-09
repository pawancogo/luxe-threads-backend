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
  validates :last_name, presence: true, unless: :pending_invitation?
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
  after_create :send_verification_email, unless: :super_admin?

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
  
  # Update last login
  def update_last_login!
    update_column(:last_login_at, Time.current)
  end
  
  # Block admin and log out all sessions
  def block!
    transaction do
      update(is_blocked: true, is_active: false)
      
      # Invalidate all active login sessions for this admin
      LoginSession.for_user(self)
                  .active
                  .where(logged_out_at: nil)
                  .update_all(
                    logged_out_at: Time.current,
                    is_active: false
                  )
      
      # Note: Rails sessions and cookies are cleared when the blocked admin
      # tries to access the system (handled in authentication middleware)
      # This ensures they must re-enter credentials on next request
    end
  end
  
  # Unblock admin
  def unblock!
    update(is_blocked: false, is_active: true)
  end

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

  # Generic verification methods
  def send_verification_email_with_temp_password
    temp_password = TempPasswordService.generate_for(self)
    VerificationMailer.verification_email(self, temp_password, 'admin').deliver_now
    temp_password
  end

  def send_password_reset_email
    temp_password = TempPasswordService.generate_for(self)
    VerificationMailer.password_reset_email(self, temp_password, 'admin').deliver_now
    temp_password
  end

  def authenticate_with_temp_password(temp_password)
    TempPasswordService.authenticate_temp_password(self, temp_password)
  end

  def reset_password_with_temp_password(temp_password, new_password)
    return false unless authenticate_with_temp_password(temp_password)
    return false unless PasswordValidationService.valid?(new_password)
    
    update!(password: new_password)
    TempPasswordService.clear_temp_password(self)
    true
  end

  def temp_password_expired?
    TempPasswordService.temp_password_expired?(self)
  end

  # Password authentication methods
  def authenticate(password)
    return false if password_digest.blank?
    PasswordHashingService.verify_password(password, password_digest)
  end

  def password=(new_password)
    @password = new_password
    self.password_digest = PasswordHashingService.hash_password(new_password) if new_password.present?
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
    
    errors = PasswordValidationService.errors(password)
    errors.each { |error| self.errors.add(:password, error) }
  end

  def password_required?
    password.present? && !password_reset_required?
  end

  def send_verification_email
    EmailVerificationService.new(self).send_verification_email
  end
end
