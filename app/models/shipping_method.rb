# frozen_string_literal: true

class ShippingMethod < ApplicationRecord
  has_many :shipments, dependent: :restrict_with_error
  
  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  
  scope :active, -> { where(is_active: true) }
  scope :cod_available, -> { where(is_cod_available: true) }
  
  # Parse available_pincodes JSON
  def available_pincodes_list
    return [] if available_pincodes.blank?
    JSON.parse(available_pincodes) rescue []
  end
  
  def available_pincodes_list=(list)
    self.available_pincodes = list.to_json
  end
  
  # Parse excluded_pincodes JSON
  def excluded_pincodes_list
    return [] if excluded_pincodes.blank?
    JSON.parse(excluded_pincodes) rescue []
  end
  
  def excluded_pincodes_list=(list)
    self.excluded_pincodes = list.to_json
  end
  
  # Parse available_zones JSON
  def available_zones_data
    return {} if available_zones.blank?
    JSON.parse(available_zones) rescue {}
  end
  
  def available_zones_data=(data)
    self.available_zones = data.to_json
  end
end



