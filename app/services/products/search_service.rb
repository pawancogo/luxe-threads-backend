# frozen_string_literal: true

# Service for handling product search with filters, pagination, and facets
# Follows SOLID principles - single responsibility for product search
module Products
  class SearchService < BaseService
    attr_reader :products, :facets, :pagination

    def initialize(params = {})
      super()
      @params = params
      @products = nil
      @facets = {}
      @pagination = {}
    end

    def call
      build_query
      apply_filters
      apply_price_filter
      apply_pagination
      build_facets
      set_result({
        products: format_products,
        facets: @facets,
        pagination: @pagination
      })
    end

    private

    def build_query
      @products = Product.active
                         .with_brand_and_category
                         .with_images

      # Apply search term
      if @params[:query].present?
        @products = @products.search_by_term(@params[:query])
      end

      # Apply flag filters
      @products = @products.featured if @params[:featured] == 'true'
      @products = @products.bestsellers if @params[:bestseller] == 'true'
      @products = @products.new_arrivals if @params[:new_arrival] == 'true'
      @products = @products.trending if @params[:trending] == 'true'
    end

    def apply_filters
      # Category filter (by ID or slug)
      if @params[:category_id].present?
        category = Category.find_by(id: @params[:category_id]) || Category.find_by(slug: @params[:category_id])
        @products = @products.where(category_id: category.id) if category
      end

      # Brand filter (by ID or slug)
      if @params[:brand_id].present?
        brand = Brand.find_by(id: @params[:brand_id]) || Brand.find_by(slug: @params[:brand_id])
        @products = @products.where(brand_id: brand.id) if brand
      end
    end

    def apply_price_filter
      return unless @params[:min_price].present? || @params[:max_price].present?

      price_filtered_products = @products.joins(:product_variants)
      price_filtered_products = price_filtered_products.where("product_variants.price >= ?", @params[:min_price].to_f) if @params[:min_price].present?
      price_filtered_products = price_filtered_products.where("product_variants.price <= ?", @params[:max_price].to_f) if @params[:max_price].present?
      @products = Product.where(id: price_filtered_products.select(:id).distinct)
    end

    def apply_pagination
      page = @params[:page]&.to_i || 1
      per_page = @params[:per_page]&.to_i || 20
      total_count = @products.count

      @pagination = {
        current_page: page,
        total_pages: (total_count.to_f / per_page).ceil,
        total_count: total_count,
        per_page: per_page
      }

      @products = @products.offset((page - 1) * per_page).limit(per_page)
    end

    def build_facets
      @facets = {
        brand_name: build_brand_facets,
        category_name: build_category_facets
      }
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

    def format_products
      @products.map do |product|
        variant = product.product_variants.first
        {
          id: product.id,
          slug: product.slug,
          name: product.name,
          description: product.description&.truncate(200),
          short_description: product.short_description,
          brand_name: product.brand.name,
          category_name: product.category.name,
          supplier_name: product.supplier_profile.company_name,
          price: variant&.price,
          discounted_price: variant&.discounted_price,
          base_price: product.base_price&.to_f,
          base_discounted_price: product.base_discounted_price&.to_f,
          image_url: variant&.product_images&.first&.image_url || product.product_variants.first&.product_images&.first&.image_url,
          stock_available: product.product_variants.any? { |v| (v.available_quantity || v.stock_quantity || 0) > 0 },
          is_featured: product.is_featured || false,
          is_bestseller: product.is_bestseller || false,
          is_new_arrival: product.is_new_arrival || false,
          is_trending: product.is_trending || false,
          average_rating: product.reviews.average(:rating)&.round(1)
        }
      end
    end
  end
end

