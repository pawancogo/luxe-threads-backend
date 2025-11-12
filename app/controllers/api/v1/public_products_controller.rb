class Api::V1::PublicProductsController < ApplicationController
  skip_before_action :authenticate_request, only: [:index, :show]

  # GET /api/v1/public/products - Public product listing (for customers)
  # Advanced filtering with Products::FilterService
  def index
    result = fetch_products_data
    
    filters_service = Products::PublicFiltersService.new
    filters_service.call
    
    response_data = {
      products: PublicProductSerializer.collection(result[:products]),
      pagination: {
        total_count: result[:total_count],
        total_pages: result[:total_pages],
        current_page: result[:current_page],
        per_page: result[:per_page]
      },
      filters_applied: result[:filters_applied],
      available_filters: filters_service.filters
    }
    
    render_success(response_data, 'Products retrieved successfully')
  end

  # GET /api/v1/public/products/:id - Public product details (for customers)
  # Phase 2: Support slug or ID lookup
  def show
    service = Products::PublicFetchService.new(params[:id])
    service.call
    
    if service.success?
      response_data = PublicProductDetailSerializer.new(service.product).as_json
      render_success(response_data, 'Product retrieved successfully')
    else
      render_not_found('Product not found')
    end
  end
  
  private
  
  def fetch_products_data
    filter_builder = Products::FilterParamsBuilder.new(params)
    filter_builder.call
    
    filter_service = Products::FilterService.new(Product.active)
    filter_service.apply(filter_builder.filters).results(
      page: (params[:page] || 1).to_i,
      per_page: (params[:per_page] || 20).to_i
    )
  end

end
