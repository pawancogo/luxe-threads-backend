class Api::V1::BrandsController < ApplicationController
  skip_before_action :authenticate_request, only: [:index, :show]

  def index
    @brands = Brand.where(active: true).order(:name).all
    render_success(format_brands_data(@brands), 'Brands retrieved successfully')
  end

  def show
    @brand = Brand.find_by(slug: params[:id]) || Brand.find(params[:id])
    render_success(format_brand_data(@brand), 'Brand retrieved successfully')
  rescue ActiveRecord::RecordNotFound
    render_not_found('Brand not found')
  end

  private

  def format_brands_data(brands)
    brands.map do |brand|
      {
        id: brand.id,
        name: brand.name,
        slug: brand.slug,
        logo_url: brand.logo_url,
        banner_url: brand.banner_url,
        short_description: brand.short_description,
        country_of_origin: brand.country_of_origin,
        founded_year: brand.founded_year,
        website_url: brand.website_url,
        products_count: brand.products_count || 0,
        active_products_count: brand.active_products_count || 0
      }
    end
  end

  def format_brand_data(brand)
    {
      id: brand.id,
      name: brand.name,
      slug: brand.slug,
      logo_url: brand.logo_url,
      banner_url: brand.banner_url,
      short_description: brand.short_description,
      country_of_origin: brand.country_of_origin,
      founded_year: brand.founded_year,
      website_url: brand.website_url,
      meta_title: brand.meta_title,
      meta_description: brand.meta_description,
      products_count: brand.products_count || 0,
      active_products_count: brand.active_products_count || 0
    }
  end

  def format_collection_data(collection)
    collection.map(&:as_json)
  end
end