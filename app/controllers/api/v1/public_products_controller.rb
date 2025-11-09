class Api::V1::PublicProductsController < ApplicationController
  skip_before_action :authenticate_request, only: [:index, :show]

  # GET /api/v1/public/products - Public product listing (for customers)
  # Advanced filtering with ProductFilterService
  def index
    # Build cache key from filters and pagination
    cache_key = "public_products:#{Digest::MD5.hexdigest(params.to_json)}"
    
    # Cache result for 5 minutes (if caching feature is enabled)
    result = if feature_enabled?(:caching)
      Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
        fetch_products_data
      end
    else
      fetch_products_data
    end
    
    render_success({
      products: format_public_products_data(result[:products]),
      pagination: {
        total_count: result[:total_count],
        total_pages: result[:total_pages],
        current_page: result[:current_page],
        per_page: result[:per_page]
      },
      filters_applied: result[:filters_applied],
      available_filters: available_filters
    }, 'Products retrieved successfully')
  end
  
  private
  
  def fetch_products_data
    filter_service = ProductFilterService.new(Product.active)
    filters = build_filters_from_params
    filter_service.apply(filters).results(
      page: (params[:page] || 1).to_i,
      per_page: (params[:per_page] || 20).to_i
    )
  end

  # GET /api/v1/public/products/:id - Public product details (for customers)
  # Phase 2: Support slug or ID lookup
  def show
    # Cache product details for 1 hour (if caching feature is enabled)
    cache_key = "public_product:#{params[:id]}"
    
    @product = if feature_enabled?(:caching)
      Rails.cache.fetch(cache_key, expires_in: 1.hour) do
        fetch_product_data
      end
    else
      fetch_product_data
    end
    
    render_success(format_public_product_detail_data(@product), 'Product retrieved successfully')
  rescue ActiveRecord::RecordNotFound
    render_not_found('Product not found')
  end
  
  def fetch_product_data
      Product.active.includes(
        :brand, 
        :category, 
        :supplier_profile,
        product_variants: [
          :product_images, 
          :product_variant_attributes,
          attribute_values: :attribute_type
        ],
        reviews: :user
      ).find_by(slug: params[:id]) || 
      Product.active.includes(
        :brand, 
        :category, 
        :supplier_profile,
        product_variants: [
          :product_images, 
          :product_variant_attributes,
          attribute_values: :attribute_type
        ],
        reviews: :user
      ).find(params[:id])
  end

  private

  # Build filters hash from request parameters
  def build_filters_from_params
    filters = {}
    
    # Price filters
    filters[:min_price] = params[:min_price] if params[:min_price].present?
    filters[:max_price] = params[:max_price] if params[:max_price].present?
    
    # Category filters
    filters[:category_id] = params[:category_id] if params[:category_id].present?
    filters[:category_slug] = params[:category_slug] if params[:category_slug].present?
    filters[:category_ids] = params[:category_ids] if params[:category_ids].present?
    
    # Brand filters
    filters[:brand_id] = params[:brand_id] if params[:brand_id].present?
    filters[:brand_slug] = params[:brand_slug] if params[:brand_slug].present?
    filters[:brand_ids] = params[:brand_ids] if params[:brand_ids].present?
    
    # Phase 2 flag filters
    filters[:featured] = params[:featured] if params[:featured].present?
    filters[:bestseller] = params[:bestseller] if params[:bestseller].present?
    filters[:new_arrival] = params[:new_arrival] if params[:new_arrival].present?
    filters[:trending] = params[:trending] if params[:trending].present?
    
    # Stock filters
    filters[:in_stock] = params[:in_stock] if params[:in_stock].present?
    
    # Rating filters
    filters[:min_rating] = params[:min_rating] if params[:min_rating].present?
    
    # Attribute filters (array of attribute_value_ids)
    filters[:attribute_values] = params[:attribute_values] if params[:attribute_values].present?
    
    # Search
    filters[:query] = params[:query] || params[:search] if (params[:query].present? || params[:search].present?)
    
    # Sorting
    filters[:sort_by] = params[:sort_by] if params[:sort_by].present?
    
    # Status
    filters[:status] = params[:status] if params[:status].present?
    
    filters
  end

  # Get available filter options for UI
  def available_filters
    {
      price_range: {
        min: ProductVariant.minimum(:discounted_price) || ProductVariant.minimum(:price) || 0,
        max: ProductVariant.maximum(:discounted_price) || ProductVariant.maximum(:price) || 10000
      },
      categories: Category.all.map { |c| { id: c.id, name: c.name, slug: c.slug } },
      brands: Brand.active.map { |b| { id: b.id, name: b.name, slug: b.slug } },
      sort_options: [
        { value: 'recommended', label: 'Recommended' },
        { value: 'price_low_high', label: 'Price: Low to High' },
        { value: 'price_high_low', label: 'Price: High to Low' },
        { value: 'newest', label: 'Newest First' },
        { value: 'oldest', label: 'Oldest First' },
        { value: 'rating', label: 'Highest Rated' },
        { value: 'popular', label: 'Most Popular' },
        { value: 'name_asc', label: 'Name: A to Z' },
        { value: 'name_desc', label: 'Name: Z to A' }
      ],
      flags: [
        { key: 'featured', label: 'Featured' },
        { key: 'bestseller', label: 'Bestseller' },
        { key: 'new_arrival', label: 'New Arrival' },
        { key: 'trending', label: 'Trending' }
      ]
    }
  end

  def format_public_products_data(products)
    products.map do |product|
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
        # Phase 2: Use available_quantity for stock check
        stock_available: product.product_variants.any? { |v| (v.available_quantity || v.stock_quantity || 0) > 0 },
        is_featured: product.is_featured || false,
        is_bestseller: product.is_bestseller || false,
        is_new_arrival: product.is_new_arrival || false,
        is_trending: product.is_trending || false,
        average_rating: product.reviews.average(:rating)&.round(1)
      }
    end
  end

  def format_public_product_detail_data(product)
    {
      id: product.id,
      slug: product.slug,
      name: product.name,
      description: product.description,
      short_description: product.short_description,
      # Phase 2: Product flags
      is_featured: product.is_featured || false,
      is_bestseller: product.is_bestseller || false,
      is_new_arrival: product.is_new_arrival || false,
      is_trending: product.is_trending || false,
      published_at: product.published_at&.iso8601,
      brand: {
        id: product.brand.id,
        name: product.brand.name,
        slug: product.brand.slug,
        logo_url: product.brand.logo_url
      },
      category: {
        id: product.category.id,
        name: product.category.name,
        slug: product.category.slug
      },
      supplier: {
        id: product.supplier_profile.id,
        company_name: product.supplier_profile.company_name,
        verified: product.supplier_profile.verified
      },
      variants: product.product_variants.map do |variant|
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
      end,
      reviews: product.reviews.order(created_at: :desc).limit(10).map do |review|
        {
          id: review.id,
          user_name: review.user.full_name,
          rating: review.rating,
          comment: review.comment,
          verified_purchase: review.verified_purchase,
          created_at: review.created_at.iso8601
        }
      end,
      average_rating: product.reviews.average(:rating)&.round(1),
      total_reviews: product.reviews.count
    }
  end
end
