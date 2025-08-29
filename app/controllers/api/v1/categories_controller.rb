class Api::V1::CategoriesController < ApplicationController
  skip_before_action :authenticate_request, only: [:index]

  def index
    @categories = Category.all
    render json: @categories
  end
end