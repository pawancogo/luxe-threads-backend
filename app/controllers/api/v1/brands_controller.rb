class Api::V1::BrandsController < ApplicationController
  skip_before_action :authenticate_request, only: [:index]

  def index
    @brands = Brand.all
    render_success(format_collection_data(@brands), 'Brands retrieved successfully')
  end
end