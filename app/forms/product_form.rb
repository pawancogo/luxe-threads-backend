# frozen_string_literal: true

# Form object for product creation and updates
# Handles complex product form validation and processing
class ProductForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :name, :string
  attribute :description, :string
  attribute :category_id, :integer
  attribute :brand_id, :integer
  attribute :supplier_profile_id, :integer
  # variants_attributes is handled manually since ActiveModel::Attributes doesn't support :array type
  # attribute_value_ids is handled manually for product-level attributes

  validates :name, presence: true, length: { minimum: 3, maximum: 255 }
  validates :description, presence: true, length: { minimum: 10 }
  validates :category_id, presence: true
  validates :brand_id, presence: true
  validates :supplier_profile_id, presence: true
  validate :category_exists
  validate :brand_exists
  validate :supplier_profile_exists
  validate :at_least_one_variant

  # Phase 2: Add Phase 2 attributes
  attribute :short_description, :string
  attribute :product_type, :string
  attribute :slug, :string
  attribute :meta_title, :string
  attribute :meta_description, :string
  attribute :meta_keywords, :string
  attribute :highlights, :string
  attribute :search_keywords, :string
  attribute :tags, :string
  attribute :base_price, :decimal
  attribute :base_discounted_price, :decimal
  attribute :base_mrp, :decimal
  attribute :length_cm, :decimal
  attribute :width_cm, :decimal
  attribute :height_cm, :decimal
  attribute :weight_kg, :decimal
  attribute :is_featured, :boolean
  attribute :is_bestseller, :boolean
  attribute :is_new_arrival, :boolean
  attribute :is_trending, :boolean
  attribute :published_at, :datetime

  def initialize(attributes = {})
    super
    @variants_attributes = attributes[:variants_attributes] || attributes['variants_attributes'] || []
    @variants_attributes = [] if @variants_attributes.blank?
    @attribute_value_ids = attributes[:attribute_value_ids] || attributes['attribute_value_ids'] || []
    @attribute_value_ids = [] if @attribute_value_ids.blank?
    @product = nil
  end
  
  def variants_attributes
    @variants_attributes ||= []
  end
  
  def variants_attributes=(value)
    @variants_attributes = value || []
  end

  def attribute_value_ids
    @attribute_value_ids ||= []
  end

  def attribute_value_ids=(value)
    @attribute_value_ids = value || []
    @attribute_value_ids = [@attribute_value_ids] unless @attribute_value_ids.is_a?(Array)
    @attribute_value_ids = @attribute_value_ids.map(&:to_i).reject(&:zero?)
  end

  def save
    return false unless valid?

    @product = Product.create(product_attributes)
    
    if @product.persisted?
      true
    else
      errors.add(:base, @product.errors.full_messages.join(', '))
      false
    end
  rescue StandardError => e
    errors.add(:base, "Failed to create product: #{e.message}")
    false
  end

  def update(product)
    return false unless valid?

    @product = product
    unless @product.update(product_attributes)
      errors.add(:base, @product.errors.full_messages.join(', '))
      return false
    end

    true
  rescue StandardError => e
    errors.add(:base, "Failed to update product: #{e.message}")
    false
  end

  def product
    @product ||= Product.new(product_attributes)
  end

  private

  def product_attributes
    {
      name: name,
      description: description,
      short_description: attributes[:short_description],
      category_id: category_id,
      brand_id: brand_id,
      supplier_profile_id: supplier_profile_id,
      product_type: attributes[:product_type],
      highlights: attributes[:highlights]&.to_json,
      search_keywords: attributes[:search_keywords]&.to_json,
      tags: attributes[:tags]&.to_json,
      base_price: attributes[:base_price],
      base_discounted_price: attributes[:base_discounted_price],
      base_mrp: attributes[:base_mrp],
      length_cm: attributes[:length_cm],
      width_cm: attributes[:width_cm],
      height_cm: attributes[:height_cm],
      weight_kg: attributes[:weight_kg],
      is_featured: attributes[:is_featured] || false,
      is_bestseller: attributes[:is_bestseller] || false,
      is_new_arrival: attributes[:is_new_arrival] || false,
      is_trending: attributes[:is_trending] || false,
      published_at: attributes[:published_at],
      status: :pending
    }.compact
  end


  def category_exists
    return if category_id.blank?
    unless Category.exists?(category_id)
      errors.add(:category_id, 'must be a valid category')
    end
  end

  def brand_exists
    return if brand_id.blank?
    unless Brand.exists?(brand_id)
      errors.add(:brand_id, 'must be a valid brand')
    end
  end

  def supplier_profile_exists
    return if supplier_profile_id.blank?
    unless SupplierProfile.exists?(supplier_profile_id)
      errors.add(:supplier_profile_id, 'must be a valid supplier profile')
    end
  end

  def at_least_one_variant
    return if variants_attributes.blank?
    
    # Check if at least one variant has required fields
    valid_variants = variants_attributes.select do |v|
      v = v.to_h if v.respond_to?(:to_h)
      v[:price].present? && v[:stock_quantity].present?
    end
    
    if valid_variants.empty?
      errors.add(:variants_attributes, 'must have at least one variant with price and stock quantity')
    end
  end

  def success?
    @product&.persisted? && errors.empty?
  end
end


