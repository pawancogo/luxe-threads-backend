class Api::V1::CategoriesController < ApplicationController
  skip_before_action :authenticate_request, only: [:index]

  def index
    @categories = Category.includes(:parent).all
    render_success(format_collection_data(@categories), 'Categories retrieved successfully')
  end
end