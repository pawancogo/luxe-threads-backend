# frozen_string_literal: true

# Service for building admin product listing queries
# Extracts query building logic from controllers
module Products
  class AdminListingService < BaseService
    attr_reader :products

    def initialize(params = {})
      super()
      @params = params
    end

    def call
      build_query
      apply_filters
      apply_pagination
      set_result(@products)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def build_query
      @products = Product.admin_listing
    end

    def apply_filters
      @products = @products.with_status(@params[:status]) if @params[:status].present?
      @products = @products.by_supplier(@params[:supplier_id]) if @params[:supplier_id].present?
      @products = @products.by_category(@params[:category_id]) if @params[:category_id].present?
      @products = @products.by_brand(@params[:brand_id]) if @params[:brand_id].present?
      @products = @products.search_by_term(@params[:search]) if @params[:search].present?
      @products = @products.created_between(@params[:created_from], @params[:created_to])
      @products = @products.order(created_at: :desc)
    end

    def apply_pagination
      page = (@params[:page] || 1).to_i
      per_page = (@params[:per_page] || 20).to_i
      @products = @products.page(page).per(per_page)
    end
  end
end

