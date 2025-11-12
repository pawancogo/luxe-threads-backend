# frozen_string_literal: true

# Serializer for Category API responses
class CategorySerializer < BaseSerializer
  attributes :id, :name, :slug, :parent_id, :level, :path,
             :short_description, :description, :image_url, :banner_url,
             :icon_url, :meta_title, :meta_description, :meta_keywords,
             :featured, :products_count, :active_products_count, :parent,
             :sub_categories

  def featured
    object.featured || false
  end

  def products_count
    object.products_count || 0
  end

  def active_products_count
    object.active_products_count || 0
  end

  def parent
    return nil unless object.parent
    
    {
      id: object.parent.id,
      name: object.parent.name,
      slug: object.parent.slug
    }
  end

  def sub_categories
    object.sub_categories.map do |sub|
      {
        id: sub.id,
        name: sub.name,
        slug: sub.slug
      }
    end
  end
end

