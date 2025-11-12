class Api::V1::CategoriesController < ApplicationController
  include SlugOrIdLookup
  
  skip_before_action :authenticate_request, only: [:index, :show, :navigation]

  def index
    @categories = Category.includes(:parent)
                          .order(:sort_order, :name)
                          .all
    render_success(
      CategorySerializer.collection(@categories),
      'Categories retrieved successfully'
    )
  end

  def show
    @category = find_by_slug_or_id(Category, params[:id])
    render_success(
      CategorySerializer.new(@category).as_json,
      'Category retrieved successfully'
    )
  rescue ActiveRecord::RecordNotFound
    render_not_found('Category not found')
  end

  def navigation
    service = CategoryNavigationService.new
    service.call
    
    if service.success?
      render_success(service.navigation_data, 'Navigation items retrieved successfully')
    else
      render_error(service.errors.first || 'Failed to retrieve navigation', :internal_server_error)
    end
  end

end