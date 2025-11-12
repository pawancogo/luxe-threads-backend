# frozen_string_literal: true

# Serializer for public product detail (customer-facing)
class PublicProductDetailSerializer < BaseSerializer
  attributes :id, :slug, :name, :description, :short_description,
             :is_featured, :is_bestseller, :is_new_arrival, :is_trending,
             :published_at, :brand, :category, :supplier, :variants,
             :reviews, :average_rating, :total_reviews

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

  def published_at
    object.published_at&.iso8601
  end

  def brand
    {
      id: object.brand.id,
      name: object.brand.name,
      slug: object.brand.slug,
      logo_url: object.brand.logo_url
    }
  end

  def category
    {
      id: object.category.id,
      name: object.category.name,
      slug: object.category.slug
    }
  end

  def supplier
    {
      id: object.supplier_profile.id,
      company_name: object.supplier_profile.company_name,
      verified: object.supplier_profile.verified
    }
  end

  def variants
    object.product_variants.map do |variant|
      {
        id: variant.id,
        sku: variant.sku,
        price: variant.price,
        discounted_price: variant.discounted_price,
        mrp: variant.mrp&.to_f,
        stock_quantity: variant.stock_quantity,
        available_quantity: variant.available_quantity || 0,
        weight_kg: variant.weight_kg,
        currency: variant.currency || 'INR',
        is_available: variant.is_available || false,
        is_low_stock: variant.is_low_stock || false,
        out_of_stock: variant.out_of_stock || false,
        images: variant.product_images.order(:display_order).map do |image|
          {
            id: image.id,
            url: image.image_url,
            thumbnail_url: image.thumbnail_url,
            medium_url: image.medium_url,
            large_url: image.large_url,
            alt_text: image.alt_text
          }
        end,
        attributes: variant.product_variant_attributes.map do |pva|
          {
            attribute_type: pva.attribute_value.attribute_type.name,
            attribute_value: pva.attribute_value.value
          }
        end
      }
    end
  end

  def reviews
    object.reviews.order(created_at: :desc).limit(10).map do |review|
      {
        id: review.id,
        user_name: review.user.full_name,
        rating: review.rating,
        comment: review.comment,
        verified_purchase: review.verified_purchase,
        created_at: review.created_at.iso8601
      }
    end
  end

  def average_rating
    object.reviews.average(:rating)&.round(1)
  end

  def total_reviews
    object.reviews.count
  end
end

