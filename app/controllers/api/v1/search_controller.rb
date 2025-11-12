# frozen_string_literal: true

# Thin controller for product search - delegates to Products::SearchService
class Api::V1::SearchController < ApplicationController
  skip_before_action :authenticate_request, only: [:search]

  def search
    service = Products::SearchService.new(search_params)
    service.call

    if service.success?
      render_success(service.result, 'Search completed successfully')
    else
      render_error(service.errors.join(', '), :unprocessable_entity)
    end
  end

  private

  def search_params
    params.permit(:query, :featured, :bestseller, :new_arrival, :trending, 
                  :category_id, :brand_id, :min_price, :max_price, 
                  :page, :per_page)
  end
end