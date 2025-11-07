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

  # Parse JSON fields
  def warehouse_addresses_array
    return [] if warehouse_addresses.blank?
    JSON.parse(warehouse_addresses) rescue []
  end

  def verification_documents_array
    return [] if verification_documents.blank?
    JSON.parse(verification_documents) rescue []
  end

  def shipping_zones_hash
    return {} if shipping_zones.blank?
    JSON.parse(shipping_zones) rescue {}
  end

  # Update JSON fields
  def update_warehouse_addresses(addresses)
    update_column(:warehouse_addresses, addresses.to_json)
  end

  def add_verification_document(document_url)
    docs = verification_documents_array
    docs << { url: document_url, uploaded_at: Time.current.iso8601 }
    update_column(:verification_documents, docs.to_json)
  end

  def suspend!(reason)
    update!(
      is_suspended: true,
      suspended_reason: reason,
      suspended_at: Time.current
    )
  end

  def activate!
    update!(
      is_suspended: false,
      suspended_reason: nil,
      suspended_at: nil
    )
  end
  
  private
  
  def owner_or_user_present
    # Must have either owner_id or user_id (for backward compatibility)
    if owner_id.blank? && user_id.blank?
      errors.add(:base, "Owner must be present")
    end
  end

  def generate_invite_code
    code = SecureRandom.alphanumeric(10).upcase
    while SupplierProfile.exists?(invite_code: code)
      code = SecureRandom.alphanumeric(10).upcase
    end
    self.invite_code = code
  end
end