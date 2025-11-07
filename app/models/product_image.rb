class ProductImage < ApplicationRecord
  belongs_to :product_variant, optional: true
  belongs_to :product, optional: true

  validates :image_url, presence: true
  validates :display_order, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :product_or_variant_present

  # Phase 2: Scopes
  scope :sorted, -> { order(:display_order, :id) }
  scope :by_type, ->(type) { where(image_type: type) }

  private

  def product_or_variant_present
    if product_id.blank? && product_variant_id.blank?
      errors.add(:base, 'Either product_id or product_variant_id must be present')
    end
  end
end