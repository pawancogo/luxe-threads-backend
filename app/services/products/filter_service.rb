# frozen_string_literal: true

# Advanced Product Filter Service
# Handles complex filtering logic for products in a scalable way
module Products
  class FilterService < BaseService
    attr_reader :products, :filters

    def initialize(base_scope = Product.active)
      super()
      @products = base_scope.includes(:brand, :category, :supplier_profile, product_variants: [:product_images])
      @filters = {}
    end

    # Apply all filters
    def call(filters_hash = {})
      @filters = filters_hash || {}
      
      apply_basic_filters
      apply_price_filters
      apply_category_filters
      apply_brand_filters
      apply_attribute_filters
      apply_rating_filters
      apply_stock_filters
      apply_phase2_flag_filters
      apply_search_filters
      apply_sorting
      
      set_result(@products)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    # Backward compatibility - alias for call
    def apply(filters_hash = {})
      call(filters_hash)
    end

    # Get filtered results with pagination
    def results(page: 1, per_page: 20)
      # Ensure page and per_page are integers
      page = page.to_i
      per_page = per_page.to_i
      # Ensure per_page is at least 1 to avoid division by zero
      per_page = 1 if per_page <= 0
      
      {
        products: @products.page(page).per(per_page),
        total_count: @products.count,
        total_pages: (@products.count.to_f / per_page.to_f).ceil,
        current_page: page,
        per_page: per_page,
        filters_applied: active_filters
      }
    end

    # Get active filters summary
    def active_filters
      filters = []
      
      filters << { type: 'price', min: @filters[:min_price], max: @filters[:max_price] } if price_filtered?
      filters << { type: 'category', value: @filters[:category_id] || @filters[:category_slug] } if category_filtered?
      filters << { type: 'brand', value: @filters[:brand_id] || @filters[:brand_slug] } if brand_filtered?
      filters << { type: 'rating', min: @filters[:min_rating] } if @filters[:min_rating].present?
      filters << { type: 'stock', value: @filters[:in_stock] } if @filters[:in_stock].present?
      filters << { type: 'featured', value: true } if @filters[:featured] == true || @filters[:featured] == 'true'
      filters << { type: 'bestseller', value: true } if @filters[:bestseller] == true || @filters[:bestseller] == 'true'
      filters << { type: 'new_arrival', value: true } if @filters[:new_arrival] == true || @filters[:new_arrival] == 'true'
      filters << { type: 'trending', value: true } if @filters[:trending] == true || @filters[:trending] == 'true'
      filters << { type: 'search', query: @filters[:query] } if @filters[:query].present?
      
      if @filters[:attribute_values].present?
        @filters[:attribute_values].each do |attr_id|
          filters << { type: 'attribute', attribute_value_id: attr_id }
        end
      end
      
      filters
    end

    private

    # Basic filters (status, etc.)
    def apply_basic_filters
      @products = @products.where(status: 'active') unless @filters[:status].present?
      @products = @products.where(status: @filters[:status]) if @filters[:status].present?
    end

    # Price range filters
    def apply_price_filters
      return unless price_filtered?
      
      if @filters[:min_price].present? || @filters[:max_price].present?
        # Filter by variant prices
        min_price = @filters[:min_price].to_f if @filters[:min_price].present?
        max_price = @filters[:max_price].to_f if @filters[:max_price].present?
        
        variant_scope = ProductVariant.select(:product_id).distinct
        
        if min_price.present? && max_price.present?
          variant_scope = variant_scope.where(
            'discounted_price BETWEEN ? AND ? OR price BETWEEN ? AND ?',
            min_price, max_price, min_price, max_price
          )
        elsif min_price.present?
          variant_scope = variant_scope.where(
            'discounted_price >= ? OR price >= ?',
            min_price, min_price
          )
        elsif max_price.present?
          variant_scope = variant_scope.where(
            'discounted_price <= ? OR price <= ?',
            max_price, max_price
          )
        end
        
        product_ids = variant_scope.pluck(:product_id)
        @products = @products.where(id: product_ids) if product_ids.any?
      end
    end

    # Category filters (ID or slug)
    def apply_category_filters
      if @filters[:category_id].present?
        @products = @products.where(category_id: @filters[:category_id])
      elsif @filters[:category_slug].present?
        category = Category.find_by(slug: @filters[:category_slug])
        @products = @products.where(category_id: category.id) if category
      elsif @filters[:category_ids].present? && @filters[:category_ids].is_a?(Array)
        @products = @products.where(category_id: @filters[:category_ids])
      end
    end

    # Brand filters (ID or slug)
    def apply_brand_filters
      if @filters[:brand_id].present?
        @products = @products.where(brand_id: @filters[:brand_id])
      elsif @filters[:brand_slug].present?
        brand = Brand.find_by(slug: @filters[:brand_slug])
        @products = @products.where(brand_id: brand.id) if brand
      elsif @filters[:brand_ids].present? && @filters[:brand_ids].is_a?(Array)
        @products = @products.where(brand_id: @filters[:brand_ids])
      end
    end

    # Attribute filters (Color, Size, Fabric, etc.)
    def apply_attribute_filters
      return unless @filters[:attribute_values].present?
      
      # Handle both array and comma-separated string
      attribute_value_ids = if @filters[:attribute_values].is_a?(Array)
        @filters[:attribute_values].map(&:to_i).compact
      elsif @filters[:attribute_values].is_a?(String)
        @filters[:attribute_values].split(',').map(&:to_i).compact
      else
        []
      end
      
      if attribute_value_ids.any?
        # Find product variants that have these attribute values
        variant_ids = ProductVariantAttribute
          .where(attribute_value_id: attribute_value_ids)
          .select(:product_variant_id)
          .distinct
          .pluck(:product_variant_id)
        
        if variant_ids.any?
          product_ids = ProductVariant
            .where(id: variant_ids)
            .select(:product_id)
            .distinct
            .pluck(:product_id)
          
          @products = @products.where(id: product_ids)
        else
          # No variants match, return empty
          @products = @products.none
        end
      end
    end

    # Rating filters
    def apply_rating_filters
      return unless @filters[:min_rating].present?
      
      min_rating = @filters[:min_rating].to_f
      
      # Products with average rating >= min_rating
      product_ids = Product
        .joins(:reviews)
        .group('products.id')
        .having('AVG(reviews.rating) >= ?', min_rating)
        .pluck('products.id')
      
      @products = @products.where(id: product_ids) if product_ids.any?
    end

    # Stock availability filters
    def apply_stock_filters
      if @filters[:in_stock] == true || @filters[:in_stock] == 'true'
        # Only products with available stock
        product_ids = ProductVariant
          .where('available_quantity > 0 OR (available_quantity IS NULL AND stock_quantity > 0)')
          .select(:product_id)
          .distinct
          .pluck(:product_id)
        
        @products = @products.where(id: product_ids) if product_ids.any?
      elsif @filters[:in_stock] == false || @filters[:in_stock] == 'false'
        # Only out of stock products
        product_ids = ProductVariant
          .where('(available_quantity IS NULL OR available_quantity <= 0) AND (stock_quantity IS NULL OR stock_quantity <= 0)')
          .select(:product_id)
          .distinct
          .pluck(:product_id)
        
        @products = @products.where(id: product_ids) if product_ids.any?
      end
    end

    # Phase 2 flag filters
    def apply_phase2_flag_filters
      @products = @products.featured if @filters[:featured] == true || @filters[:featured] == 'true'
      @products = @products.bestsellers if @filters[:bestseller] == true || @filters[:bestseller] == 'true'
      @products = @products.new_arrivals if @filters[:new_arrival] == true || @filters[:new_arrival] == 'true'
      @products = @products.trending if @filters[:trending] == true || @filters[:trending] == 'true'
    end

    # Search filters (name, description, SKU)
    def apply_search_filters
      return unless @filters[:query].present?
      
      query = @filters[:query].to_s.strip
      return if query.blank?
      
      # Search in product name, description, short_description
      search_term = "%#{query}%"
      
      # Database-agnostic search
      adapter = ActiveRecord::Base.connection.adapter_name.downcase
      is_postgresql = adapter.include?('postgresql')
      
      # Also search in variants (SKU, attributes)
      if is_postgresql
        variant_ids = ProductVariant
          .where('sku ILIKE ?', search_term)
          .select(:product_id)
          .distinct
          .pluck(:product_id)
        
        @products = @products.where(
          'name ILIKE ? OR description ILIKE ? OR short_description ILIKE ? OR id IN (?)',
          search_term, search_term, search_term, variant_ids
        )
      else
        # SQLite: Use UPPER() for case-insensitive search
        variant_ids = ProductVariant
          .where('UPPER(sku) LIKE UPPER(?)', search_term)
          .select(:product_id)
          .distinct
          .pluck(:product_id)
        
        @products = @products.where(
          'UPPER(name) LIKE UPPER(?) OR UPPER(description) LIKE UPPER(?) OR UPPER(short_description) LIKE UPPER(?) OR id IN (?)',
          search_term, search_term, search_term, variant_ids
        )
      end
    end

    # Sorting
    def apply_sorting
      sort_by = @filters[:sort_by] || 'recommended'
      
      case sort_by.to_s
      when 'price_low_high'
        @products = @products.joins(:product_variants)
                            .group('products.id')
                            .order('MIN(product_variants.discounted_price) ASC, MIN(product_variants.price) ASC')
      when 'price_high_low'
        @products = @products.joins(:product_variants)
                            .group('products.id')
                            .order('MAX(product_variants.discounted_price) DESC, MAX(product_variants.price) DESC')
      when 'newest'
        @products = @products.order(created_at: :desc)
      when 'oldest'
        @products = @products.order(created_at: :asc)
      when 'rating'
        @products = @products.joins(:reviews)
                            .group('products.id')
                            .order('AVG(reviews.rating) DESC')
      when 'popular'
        @products = @products.order(total_clicks_count: :desc)
      when 'name_asc'
        @products = @products.order(name: :asc)
      when 'name_desc'
        @products = @products.order(name: :desc)
      else # 'recommended' or default
        # Default: featured first, then by popularity
        @products = @products.order(
          Arel.sql("CASE WHEN is_featured THEN 0 ELSE 1 END"),
          total_clicks_count: :desc,
          created_at: :desc
        )
      end
    end

    # Helper methods
    def price_filtered?
      @filters[:min_price].present? || @filters[:max_price].present?
    end

    def category_filtered?
      @filters[:category_id].present? || @filters[:category_slug].present? || 
      (@filters[:category_ids].present? && @filters[:category_ids].is_a?(Array))
    end

    def brand_filtered?
      @filters[:brand_id].present? || @filters[:brand_slug].present? ||
      (@filters[:brand_ids].present? && @filters[:brand_ids].is_a?(Array))
    end
  end
end
