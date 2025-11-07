class User < ApplicationRecord
  extend SearchManager
  
  # Include concerns for shared behavior
  include Passwordable
  include Verifiable
  include Auditable
  
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
  before_destroy :handle_dependent_deletions

  # Scopes
  scope :active, -> { where(deleted_at: nil) }
  scope :inactive, -> { where.not(deleted_at: nil) }
  scope :non_suppliers, -> { where.not(role: 'supplier') }
  scope :suppliers_only, -> { where(role: 'supplier') }
  scope :customers_only, -> { where.not(role: 'supplier') }

  # Validations
  validates :first_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true

  # Helper methods for customer roles
  def premium?
    premium_customer? || vip_customer?
  end

  def vip?
    vip_customer?
  end

  # Check if user is a supplier (has supplier_profile)
  def supplier?
    supplier_profile.present? || role == 'supplier'
  end

  # Check if user owns a supplier profile
  def supplier_owner?
    owned_supplier_profiles.exists?
  end

  # Get primary supplier profile (owned or associated)
  def primary_supplier_profile
    owned_supplier_profiles.first || supplier_profile
  end

  # Check if user is part of a supplier account
  def supplier_account_member?
    supplier_account_users.exists?
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  # Generate referral code if not present
  def generate_referral_code
    return referral_code if referral_code.present?
    
    code = SecureRandom.alphanumeric(8).upcase
    while User.exists?(referral_code: code)
      code = SecureRandom.alphanumeric(8).upcase
    end
    update_column(:referral_code, code)
    code
  end

  # Parse notification preferences JSON
  def notification_preferences_hash
    return {} if notification_preferences.blank?
    JSON.parse(notification_preferences) rescue {}
  end

  # Update notification preference
  def update_notification_preference(key, value)
    prefs = notification_preferences_hash
    prefs[key.to_s] = value
    update_column(:notification_preferences, prefs.to_json)
  end

  # Business logic methods - delegate to services
  def send_verification_email_with_temp_password
    temp_password = TempPasswordService.generate_for(self)
    VerificationMailer.verification_email(self, temp_password, 'user').deliver_now
    temp_password
  end

  def send_password_reset_email
    temp_password = TempPasswordService.generate_for(self)
    VerificationMailer.password_reset_email(self, temp_password, 'user').deliver_now
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
  
  private
  
  def handle_dependent_deletions
    # Nullify order foreign keys first to prevent constraint violations
    orders.update_all(shipping_address_id: nil, billing_address_id: nil) if orders.exists?
    
    # Delete associations using Rails associations (bypasses callbacks)
    orders.delete_all
    addresses.delete_all
    reviews.delete_all
    
    # Delete cart and wishlist with items
    cart&.cart_items&.delete_all
    cart&.delete
    wishlist&.wishlist_items&.delete_all
    wishlist&.delete
    
    # Delete return requests if model exists
    delete_return_requests
    
    # Delete supplier profile and products
    if supplier_profile.present?
      supplier_profile.products&.delete_all
      supplier_profile.delete
    end
    
    true
  rescue StandardError => e
    Rails.logger.error "Error in handle_dependent_deletions for user #{id}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n") if Rails.logger.level <= Logger::ERROR
    true # Continue with deletion even if cleanup fails
  end
  
  def delete_return_requests
    return unless model_exists?('ReturnRequest')
    
    ReturnRequest.where(user_id: id).find_each(&:destroy)
  rescue StandardError => e
    Rails.logger.error "Error deleting return requests for user #{id}: #{e.message}"
  end
  
  def model_exists?(model_name)
    model_name.constantize.table_exists?
  rescue NameError, NoMethodError
    false
  end
end