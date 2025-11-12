# frozen_string_literal: true

# Serializer for Brand API responses
class BrandSerializer < BaseSerializer
  attributes :id, :name, :slug, :logo_url, :banner_url, :short_description,
             :country_of_origin, :founded_year, :website_url, :meta_title,
             :meta_description, :products_count, :active_products_count

  def products_count
    object.products_count || 0
  end

  def active_products_count
    object.active_products_count || 0
  end
end

