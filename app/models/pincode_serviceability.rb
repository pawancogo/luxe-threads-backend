# frozen_string_literal: true

class PincodeServiceability < ApplicationRecord
  self.table_name = 'pincode_serviceability'
  
  validates :pincode, presence: true, uniqueness: true
  
  scope :serviceable, -> { where(is_serviceable: true) }
  scope :cod_available, -> { where(is_cod_available: true) }
  scope :by_pincode, ->(pincode) { where(pincode: pincode) }
  scope :by_city, ->(city) { where(city: city) }
  scope :by_state, ->(state) { where(state: state) }
  
  # Check if pincode is serviceable
  def self.serviceable?(pincode)
    by_pincode(pincode).serviceable.exists?
  end
  
  # Check if COD is available
  def self.cod_available?(pincode)
    by_pincode(pincode).cod_available.exists?
  end
  
  # Get delivery days
  def delivery_days(shipping_method = 'standard')
    case shipping_method
    when 'express'
      express_delivery_days || standard_delivery_days
    else
      standard_delivery_days
    end
  end
end

