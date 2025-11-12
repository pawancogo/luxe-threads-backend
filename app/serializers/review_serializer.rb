# frozen_string_literal: true

# Serializer for Review API responses
class ReviewSerializer < BaseSerializer
  def serialize
    {
      id: object.id,
      product_id: object.product_id,
      user_id: object.user_id,
      user_name: object.user&.full_name,
      rating: object.rating,
      title: object.title,
      comment: object.comment,
      moderation_status: object.moderation_status,
      is_featured: format_boolean(object.is_featured),
      is_verified_purchase: format_boolean(object.is_verified_purchase || false),
      review_images: object.review_images_list || [],
      helpful_count: object.helpful_count || 0,
      not_helpful_count: object.not_helpful_count || 0,
      supplier_response: object.supplier_response,
      supplier_response_at: format_date(object.supplier_response_at),
      created_at: format_date(object.created_at),
      updated_at: format_date(object.updated_at),
      user: serialize_user,
      product: serialize_product
    }
  end

  private

  def serialize_user
    return nil unless object.user
    
    {
      id: object.user.id,
      full_name: object.user.full_name,
      email: object.user.email # Consider hiding in production
    }
  end

  def serialize_product
    return nil unless object.product
    
    {
      id: object.product.id,
      name: object.product.name
    }
  end
end

