# frozen_string_literal: true

class Warehouse < ApplicationRecord
  belongs_to :supplier_profile
  has_many :warehouse_inventory, dependent: :destroy
  
  validates :name, presence: true
  validates :code, presence: true, uniqueness: { scope: :supplier_profile_id }
  validates :address, presence: true
  
  scope :active, -> { where(is_active: true) }
  scope :primary, -> { where(is_primary: true) }
  
  # Ensure only one primary warehouse per supplier
  before_save :ensure_single_primary
  
  private
  
  def ensure_single_primary
    return unless is_primary?
    
    # Unset other primary warehouses for this supplier
    Warehouse.where(supplier_profile_id: supplier_profile_id)
             .where.not(id: id)
             .update_all(is_primary: false)
  end
end

