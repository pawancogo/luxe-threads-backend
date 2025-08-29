class Api::V1::SearchController < ApplicationController
  skip_before_action :authenticate_request, only: [:search]

  def search
    # Build the filters from query parameters
    filters = {}
    filters[:brand_name] = params[:brand] if params[:brand].present?
    filters[:category_name] = params[:category] if params[:category].present?
    # Add price range filter
    filters["variants.price"] = range_filter(params[:min_price], params[:max_price]) if params[:min_price] || params[:max_price]

    # Execute the search query
    @products = Product.search(
      params[:query].presence || "*",
      where: filters,
      aggs: { # aggs (aggregations) are used to create the filter facets
        brand_name: { limit: 10 },
        category_name: { limit: 10 }
      },
      page: params[:page] || 1,
      per_page: params[:per_page] || 20
    )

    render json: {
      products: @products.results,
      facets: @products.aggs,
      pagination: {
        current_page: @products.page,
        total_pages: @products.total_pages,
        total_count: @products.total_count
      }
    }
  end

  private

  def range_filter(min, max)
    range = {}
    range[:gte] = min.to_f if min.present?
    range[:lte] = max.to_f if max.present?
    range
  end
end