# frozen_string_literal: true

class ShippingMethod < ApplicationRecord
  has_many :shipments, dependent: :restrict_with_error
  
  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  
  scope :active, -> { where(is_active: true) }
  scope :cod_available, -> { where(is_cod_available: true) }
  
  # Include JSON parsing concern
  include JsonParseable
  
  # Parse JSON fields using concern
  json_list_parser :available_pincodes, :excluded_pincodes
  json_hash_parser :available_zones
  
  # Setters for form handling (keep for backward compatibility)
  def available_pincodes_list=(list)
    self.available_pincodes = list.to_json
  end
  
  def excluded_pincodes_list=(list)
    self.excluded_pincodes = list.to_json
  end
  
  def available_zones_data=(data)
    self.available_zones = data.to_json
  end
  
  # Alias for backward compatibility
  alias_method :available_zones_data, :available_zones_hash
end



