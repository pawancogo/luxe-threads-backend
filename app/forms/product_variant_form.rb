# frozen_string_literal: true

# Form object for product variant creation
# Handles variant validation and creation with images
class ProductVariantForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :sku, :string
  attribute :price, :decimal
  attribute :discounted_price, :decimal
  attribute :stock_quantity, :integer
  attribute :weight_kg, :decimal
  attribute :product_id, :integer
  # image_urls is handled manually since ActiveModel::Attributes doesn't support :array type

  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :product_id, presence: true
  validate :product_exists
  validate :discounted_price_valid

  def initialize(attributes = {})
    super
    @image_urls = attributes[:image_urls] || attributes['image_urls'] || []
    @image_urls = [] if @image_urls.blank?
    @attribute_value_ids = attributes[:attribute_value_ids] || attributes['attribute_value_ids'] || []
    @attribute_value_ids = [] if @attribute_value_ids.blank?
    @variant = nil
  end
  
  def image_urls
    @image_urls ||= []
  end
  
  def image_urls=(value)
    @image_urls = value || []
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

    ActiveRecord::Base.transaction do
      create_variant
      create_images if @variant.persisted?
      create_attributes if @variant.persisted?
    end

    success?
  rescue StandardError => e
    Rails.logger.error "ProductVariantForm save failed: #{e.message}"
    errors.add(:base, "Failed to create variant: #{e.message}")
    false
  end

  def update(variant)
    return false unless valid?

    @variant = variant
    ActiveRecord::Base.transaction do
      update_variant
      update_images if @variant.persisted?
      update_attributes if @variant.persisted?
    end

    success?
  rescue StandardError => e
    Rails.logger.error "ProductVariantForm update failed: #{e.message}"
    errors.add(:base, "Failed to update variant: #{e.message}")
    false
  end

  def variant
    @variant
  end

  private

  def update_variant
    unless @variant.update(variant_attributes)
      errors.add(:base, @variant.errors.full_messages.join(', '))
      raise ActiveRecord::RecordInvalid, @variant
    end
  end

  def update_images
    # Remove old images if needed
    @variant.product_images.destroy_all
    
    # Create new images
    create_images
  end

  def variant_attributes
    {
      sku: sku.presence, # Will be auto-generated if blank
      price: price,
      discounted_price: discounted_price,
      stock_quantity: stock_quantity,
      weight_kg: weight_kg,
      product_id: product_id
    }.compact
  end

  def create_variant
    @variant = ProductVariant.create!(variant_attributes)
    errors.add(:base, @variant.errors.full_messages.join(', ')) unless @variant.persisted?
  end

  def create_images
    return if image_urls.blank?

    image_urls.each_with_index do |url, index|
      next if url.blank?
      ProductImage.create!(
        product_variant_id: @variant.id,
        image_url: url,
        display_order: index,
        alt_text: "#{@variant.product.name} - Image #{index + 1}"
      )
    end
  end

  def create_attributes
    return if attribute_value_ids.blank?

    attribute_value_ids.each do |attribute_value_id|
      next unless AttributeValue.exists?(attribute_value_id)
      ProductVariantAttribute.find_or_create_by!(
        product_variant_id: @variant.id,
        attribute_value_id: attribute_value_id
      )
    end
  end

  def update_attributes
    # Remove old attributes
    @variant.product_variant_attributes.destroy_all
    
    # Create new attributes
    create_attributes
  end

  def product_exists
    return if product_id.blank?
    unless Product.exists?(product_id)
      errors.add(:product_id, 'must be a valid product')
    end
  end

  def discounted_price_valid
    return if discounted_price.blank?
    if discounted_price >= price
      errors.add(:discounted_price, 'must be less than regular price')
    end
  end

  def success?
    @variant&.persisted? && errors.empty?
  end
end

