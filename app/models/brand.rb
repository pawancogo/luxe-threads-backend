class Brand < ApplicationRecord
  # Associations
  has_many :products, dependent: :destroy

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :slug, uniqueness: true, allow_nil: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :sorted, -> { order(:name) }

  # Callbacks
  before_validation :generate_slug, if: -> { slug.blank? && name.present? }

  private

  def generate_slug
    self.slug = name.parameterize if name.present?
  end
end