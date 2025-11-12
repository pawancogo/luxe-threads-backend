class Api::V1::BrandsController < ApplicationController
  include SlugOrIdLookup
  
  skip_before_action :authenticate_request, only: [:index, :show]

  def index
    @brands = Brand.where(active: true).order(:name).all
    render_success(
      BrandSerializer.collection(@brands),
      'Brands retrieved successfully'
    )
  end

  def show
    @brand = find_by_slug_or_id(Brand, params[:id])
    render_success(
      BrandSerializer.new(@brand).as_json,
      'Brand retrieved successfully'
    )
  rescue ActiveRecord::RecordNotFound
    render_not_found('Brand not found')
  end
end