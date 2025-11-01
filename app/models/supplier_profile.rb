class SupplierProfile < ApplicationRecord
  belongs_to :supplier
  has_many :products, dependent: :destroy

  validates :company_name, presence: true
  validates :gst_number, presence: true, uniqueness: true
end