# frozen_string_literal: true

# Serializer for public product listing (customer-facing)
class PublicProductSerializer < BaseSerializer
  attributes :id, :slug, :name, :description, :short_description,
             :brand_name, :category_name, :supplier_name,
             :price, :discounted_price, :base_price, :base_discounted_price,
             :image_url, :stock_available, :is_featured, :is_bestseller,
             :is_new_arrival, :is_trending, :average_rating

  def brand_name
    object.brand.name
  end

  def category_name
    object.category.name
  end

  def supplier_name
    object.supplier_profile.company_name
  end

  def price
    first_variant&.price
  end

  def discounted_price
    first_variant&.discounted_price
  end

  def base_price
    object.base_price&.to_f
  end

  def base_discounted_price
    object.base_discounted_price&.to_f
  end

  def image_url
    first_variant&.product_images&.first&.image_url ||
      object.product_variants.first&.product_images&.first&.image_url
  end

  def stock_available
    object.product_variants.any? { |v| (v.available_quantity || v.stock_quantity || 0) > 0 }
  end

  def is_featured
    object.is_featured || false
  end

  def is_bestseller
    object.is_bestseller || false
  end

  def is_new_arrival
    object.is_new_arrival || false
  end

  def is_trending
    object.is_trending || false
  end

  def average_rating
    object.reviews.average(:rating)&.round(1)
  end

  def description
    object.description&.truncate(200)
  end

  private

  def first_variant
    object.product_variants.first
  end
end

