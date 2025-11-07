class Category < ApplicationRecord
  extend SearchManager
  
  # Associations
  has_many :products, dependent: :destroy
  belongs_to :parent, class_name: 'Category', optional: true
  has_many :sub_categories, class_name: 'Category', foreign_key: 'parent_id', dependent: :destroy
  
  # Search manager configuration
  search_manager on: [:name, :slug], aggs_on: [:featured, :level]

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :slug, uniqueness: true, allow_nil: true

  # Scopes
  scope :featured, -> { where(featured: true) }
  scope :root_categories, -> { where(parent_id: nil) }
  scope :by_level, ->(level) { where(level: level) }
  scope :sorted, -> { order(:sort_order, :name) }

  # Callbacks
  before_validation :generate_slug, if: -> { slug.blank? && name.present? }
  before_save :update_path_and_level, if: -> { parent_id_changed? || name_changed? }

  # Phase 2: JSON field helpers
  def require_brand_hash
    return {} if require_brand.blank?
    JSON.parse(require_brand) rescue {}
  end

  def require_attributes_array
    return [] if require_attributes.blank?
    JSON.parse(require_attributes) rescue []
  end

  private

  def generate_slug
    self.slug = name.parameterize if name.present?
  end

  def update_path_and_level
    if parent_id.present? && parent
      self.level = parent.level + 1
      self.path = "#{parent.path} > #{name}"
    else
      self.level = 0
      self.path = name
    end
  end
end