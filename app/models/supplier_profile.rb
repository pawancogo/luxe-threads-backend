# Ensure validator is loaded before model is defined
require_relative '../validators/gst_number_validator'

class SupplierProfile < ApplicationRecord
  # Associations
  belongs_to :supplier, optional: true
  belongs_to :user, optional: true
  has_many :products, dependent: :destroy

  # Validations
  validates :company_name, presence: true
  validates :gst_number, presence: true, uniqueness: true, gst_number: true
  
  # Custom validations
  validate :supplier_or_user_present
  
  private
  
  def supplier_or_user_present
    if supplier_id.blank? && user_id.blank?
      errors.add(:base, "Either supplier or user must be present")
    end
    
    if supplier_id.present? && user_id.present?
      errors.add(:base, "Cannot belong to both supplier and user")
    end
  end
end