class Api::V1::SearchController < ApplicationController
  skip_before_action :authenticate_request, only: [:search]

  def search
    # Build query for active products
    @products = Product.active.includes(:brand, :category, product_variants: [:product_images])
    
    # Apply filters
    if params[:query].present?
      query = params[:query].downcase
      @products = @products.where("LOWER(name) LIKE ? OR LOWER(description) LIKE ?", "%#{query}%", "%#{query}%")
    end
    
    if params[:category_id].present?
      @products = @products.where(category_id: params[:category_id])
    end
    
    if params[:brand_id].present?
      @products = @products.where(brand_id: params[:brand_id])
    end
    
    # Price filtering
    if params[:min_price].present? || params[:max_price].present?
      price_filtered_products = @products.joins(:product_variants)
      price_filtered_products = price_filtered_products.where("product_variants.price >= ?", params[:min_price].to_f) if params[:min_price].present?
      price_filtered_products = price_filtered_products.where("product_variants.price <= ?", params[:max_price].to_f) if params[:max_price].present?
      @products = Product.where(id: price_filtered_products.select(:id).distinct)
    end
    
    # Pagination
    page = params[:page]&.to_i || 1
    per_page = params[:per_page]&.to_i || 20
    total_count = @products.count
    @products = @products.offset((page - 1) * per_page).limit(per_page)
    
    # Build facets (aggregations)
    facets = {
      brand_name: build_brand_facets,
      category_name: build_category_facets
    }
    
    render_success({
      products: format_search_products(@products),
      facets: facets,
      pagination: {
        current_page: page,
        total_pages: (total_count.to_f / per_page).ceil,
        total_count: total_count,
        per_page: per_page
      }
    }, 'Search completed successfully')
  end

  private

  def format_search_products(products)
    products.map do |product|
      variant = product.product_variants.first
      {
        id: product.id,
        name: product.name,
        description: product.description&.truncate(200),
        brand_name: product.brand.name,
        category_name: product.category.name,
        supplier_name: product.supplier_profile.company_name,
        price: variant&.price,
        discounted_price: variant&.discounted_price,
        image_url: variant&.product_images&.first&.image_url || product.product_variants.first&.product_images&.first&.image_url,
        stock_available: product.product_variants.any? { |v| v.stock_quantity > 0 },
        average_rating: product.reviews.average(:rating)&.round(1)
      }
    end
  end

  def build_brand_facets
    Product.active.joins(:brand)
          .group('brands.name')
          .count
          .map { |name, count| { name: name, count: count } }
  end

  def build_category_facets
    Product.active.joins(:category)
          .group('categories.name')
          .count
          .map { |name, count| { name: name, count: count } }
  end
end