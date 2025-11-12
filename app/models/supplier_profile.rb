# Ensure validator is loaded before model is defined
require_relative '../validators/gst_number_validator'

class SupplierProfile < ApplicationRecord
  # Associations
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_id', optional: true
  belongs_to :user, optional: true  # Legacy field for backward compatibility
  has_many :supplier_account_users, dependent: :destroy
  has_many :users, through: :supplier_account_users
  has_many :products, dependent: :destroy
  
  # Active Storage attachments for KYC documents
  has_many_attached :kyc_documents

  # Enums
  enum :supplier_tier, {
    basic: 'basic',
    verified: 'verified',
    premium: 'premium',
    partner: 'partner'
  }, default: 'basic'

  enum :payment_cycle, {
    daily: 'daily',
    weekly: 'weekly',
    biweekly: 'biweekly',
    monthly: 'monthly'
  }, default: 'weekly'

  # Validations
  validates :company_name, presence: true
  validates :gst_number, presence: true, uniqueness: true, gst_number: true
  validates :owner_id, presence: true, on: :create
  validates :supplier_tier, inclusion: { in: supplier_tiers.keys }
  validates :max_users, numericality: { greater_than_or_equal_to: 1 }
  validates :invite_code, uniqueness: true, allow_nil: true
  
  # Custom validations
  validate :owner_or_user_present
  
  # Scopes
  scope :active, -> { where(is_active: true, is_suspended: false) }
  scope :suspended, -> { where(is_suspended: true) }
  scope :by_tier, ->(tier) { where(supplier_tier: tier) }
  
  # Callbacks
  before_validation :generate_invite_code, if: -> { allow_invites? && invite_code.blank? }
  
  # Helper methods
  def owner_user
    owner || user
  end

  def can_add_more_users?
    supplier_account_users.count < max_users
  end

  def tier_upgrade!(new_tier)
    return false unless SupplierProfile.supplier_tiers.key?(new_tier.to_s)
    
    update!(
      supplier_tier: new_tier,
      tier_upgraded_at: Time.current
    )
  end

  # Include JSON parsing concern
  include JsonParseable
  
  # Parse JSON fields using concern
  json_array_parser :warehouse_addresses, :verification_documents
  json_hash_parser :shipping_zones

  # Update JSON fields using concern methods
  def update_warehouse_addresses(addresses)
    update_json_array(:warehouse_addresses, addresses)
  end

  def add_verification_document(document_url)
    docs = parse_json_array(:verification_documents)
    docs << { url: document_url, uploaded_at: Time.current.iso8601 }
    update_json_array(:verification_documents, docs)
  end

  def suspend!(reason)
    update!(
      is_suspended: true,
      suspended_reason: reason,
      suspended_at: Time.current
    )
  end

  # Note: activate! method removed - use Suppliers::StatusUpdateService instead
  
  private
  
  def owner_or_user_present
    # Must have either owner_id or user_id (for backward compatibility)
    if owner_id.blank? && user_id.blank?
      errors.add(:base, "Owner must be present")
    end
  end

  # Include token generation concern
  include TokenGeneratable
  
  def generate_invite_code
    self.invite_code = generate_unique_token_for(:invite_code, length: 10, method: :alphanumeric).upcase
  end
end