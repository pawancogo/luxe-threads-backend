# frozen_string_literal: true

class InventoryTransaction < ApplicationRecord
  belongs_to :product_variant
  belongs_to :supplier_profile
  belongs_to :performed_by, class_name: 'User', optional: true
  
  # Transaction types
  enum :transaction_type, {
    purchase: 'purchase',
    sale: 'sale',
    return: 'return',
    adjustment: 'adjustment',
    transfer: 'transfer',
    damage: 'damage',
    expiry: 'expiry'
  }
  
  validates :transaction_id, presence: true, uniqueness: true
  validates :transaction_type, presence: true
  validates :quantity, presence: true, numericality: { other_than: 0 }
  validates :balance_after, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  # Generate transaction_id
  before_validation :generate_transaction_id, on: :create
  
  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(transaction_type: type) }
  scope :by_product_variant, ->(variant_id) { where(product_variant_id: variant_id) }
  
  private
  
  def generate_transaction_id
    return if transaction_id.present?
    self.transaction_id = "INV-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
  end
end

