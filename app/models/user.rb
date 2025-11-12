class User < ApplicationRecord
  extend SearchManager
  
  # Include concerns for shared behavior
  include Passwordable
  include Verifiable
  include Auditable
  include Invitable
  include SupplierRoleable
  include Nameable
  
  # Search manager configuration
  search_manager on: [:email, :first_name, :last_name], aggs_on: [:role, :is_active, :email_verified]

  # Define customer roles using an enum
  enum :role, {
    customer: 'customer',
    premium_customer: 'premium_customer',
    vip_customer: 'vip_customer',
    supplier: 'supplier'
  }

  # Associations - keep only associations here
  # Note: We handle deletions manually in handle_dependent_deletions to avoid failures
  has_one :supplier_profile, dependent: :delete  # Use delete to bypass callbacks
  has_many :owned_supplier_profiles, class_name: 'SupplierProfile', foreign_key: 'owner_id', dependent: :delete_all
  has_many :supplier_account_users, dependent: :delete_all  # Multi-user supplier accounts
  has_many :supplier_profiles, through: :supplier_account_users
  # Products through supplier_profile (for backward compatibility in views)
  has_many :products, through: :supplier_profile, source: :products
  has_many :addresses, dependent: :delete_all    # Use delete_all to bypass callbacks
  has_many :orders, dependent: :destroy, counter_cache: true
  has_many :reviews, dependent: :delete_all      # Use delete_all to bypass callbacks
  has_one :cart, dependent: :delete              # Use delete to bypass callbacks
  has_one :wishlist, dependent: :delete           # Use delete to bypass callbacks
  belongs_to :referred_by, class_name: 'User', optional: true
  has_many :referred_users, class_name: 'User', foreign_key: 'referred_by_id'
  
  # Phase 4: Supporting features associations
  has_many :notifications, dependent: :destroy
  has_one :notification_preference, dependent: :destroy
  has_many :support_tickets, dependent: :destroy
  has_many :loyalty_points_transactions, dependent: :destroy
  has_many :product_views, dependent: :destroy
  has_many :user_searches, dependent: :destroy
  has_many :referrals, class_name: 'Referral', foreign_key: 'referrer_id', dependent: :destroy
  has_many :referred_records, class_name: 'Referral', foreign_key: 'referred_id', dependent: :destroy
  # Note: verified_products references Admin, not User - no dependent needed
  
  # Handle deletion order - Orders must be deleted before Addresses
  # Note: RailsAdmin uses UserPermanentDeletionService which handles cleanup before really_destroy!
  # This callback handles cleanup for regular destroy calls (soft delete)
  # Delegates to Users::DeletionService for proper separation of concerns
  before_destroy :handle_dependent_deletions

  # Scopes
  scope :active, -> { where(deleted_at: nil) }
  scope :inactive, -> { where.not(deleted_at: nil) }
  scope :suppliers_only, -> { where(role: 'supplier') }
  scope :customers_only, -> { where.not(role: 'supplier') }
  scope :by_role, ->(role) { where(role: role) if role.present? }
  scope :by_email, ->(email) { where('email LIKE ?', "%#{email}%") if email.present? }
  scope :search_by_name, ->(term) {
    return all if term.blank?
    where('first_name LIKE ? OR last_name LIKE ?', "%#{term}%", "%#{term}%")
  }
  scope :with_active_status, ->(active) {
    return all if active.nil?
    active == 'true' ? where(deleted_at: nil) : where.not(deleted_at: nil)
  }
  scope :with_supplier_profile, -> { includes(:supplier_profile, :owned_supplier_profiles) }
  scope :search_by_company_name, ->(term) {
    return all if term.blank?
    joins(:supplier_profile).where('supplier_profiles.company_name LIKE ?', "%#{term}%")
  }
  scope :with_verified_supplier_profile, ->(verified) {
    return all if verified.nil?
    verified == 'true' ? joins(:supplier_profile).where(supplier_profiles: { verified: true }) : 
                         joins(:supplier_profile).where(supplier_profiles: { verified: false })
  }

  # Associations for invitations
  belongs_to :invited_by, class_name: 'User', foreign_key: 'invited_by_id', optional: true
  has_many :invited_users, class_name: 'User', foreign_key: 'invited_by_id', dependent: :nullify

  # Validations
  validates :first_name, presence: true, unless: :pending_invitation?
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true
  
  # Ensure first name is present after invitation is accepted
  validate :names_present_after_acceptance, if: :invitation_accepted?
  
  def names_present_after_acceptance
    if invitation_accepted? && first_name.blank?
      errors.add(:base, 'First name is required after accepting invitation')
    end
  end

  # Helper methods for customer roles
  def premium?
    premium_customer? || vip_customer?
  end

  def vip?
    vip_customer?
  end

  # Generate referral code - delegates to service
  # Kept for backward compatibility, but prefer using UserReferralCodeService directly
  def generate_referral_code
    service = UserReferralCodeService.new(self)
    service.call
    service.referral_code
  end

  # Business logic methods - delegate to services
  # Note: Email sending is handled by services (EmailVerificationService, PasswordResetService)
  # These methods are kept for backward compatibility but should use services directly
  
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
  
  private
  
  # Delegates to UserDeletionService for proper cleanup
  def handle_dependent_deletions
    service = Users::DeletionService.new(self)
    service.call
    
    unless service.success?
      Rails.logger.error "Error in handle_dependent_deletions for user #{id}: #{service.errors.join(', ')}"
    end
    
    true # Continue with deletion even if cleanup fails
  rescue StandardError => e
    Rails.logger.error "Error in handle_dependent_deletions for user #{id}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n") if Rails.logger.level <= Logger::ERROR
    true # Continue with deletion even if cleanup fails
  end
end