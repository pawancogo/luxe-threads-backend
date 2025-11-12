# frozen_string_literal: true

# Serializer for admin product API responses
class AdminProductSerializer < BaseSerializer
  attributes :id, :name, :slug, :description, :short_description, :status,
             :supplier, :category, :brand, :base_price, :is_featured,
             :is_bestseller, :verified_at, :verified_by, :rejection_reason,
             :created_at, :variants_count, :highlights, :tags, :variants

  def supplier
    return nil unless object.supplier_profile
    
    {
      id: object.supplier_profile.id,
      company_name: object.supplier_profile.company_name
    }
  end

  def category
    return nil unless object.category
    
    {
      id: object.category.id,
      name: object.category.name
    }
  end

  def brand
    return nil unless object.brand
    
    {
      id: object.brand.id,
      name: object.brand.name
    }
  end

  def base_price
    object.base_price&.to_f
  end

  def verified_by
    object.verified_by_admin&.full_name
  end

  def variants_count
    object.product_variants.count
  end

  def highlights
    object.highlights_array
  end

  def tags
    object.tags_array
  end

  def variants
    object.product_variants.map do |variant|
      {
        id: variant.id,
        sku: variant.sku,
        price: variant.price.to_f,
        stock_quantity: variant.stock_quantity,
        status: variant.out_of_stock? ? 'out_of_stock' : 'in_stock'
      }
    end
  end
end

