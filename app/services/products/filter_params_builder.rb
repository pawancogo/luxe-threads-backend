# frozen_string_literal: true

# Service for building filter parameters from request params
# Extracts filter building logic from controllers
module Products
  class FilterParamsBuilder < BaseService
    attr_reader :filters

    def initialize(params)
      super()
      @params = params
    end

    def call
      build_filters
      set_result(@filters)
      self
    end

    private

    def build_filters
      @filters = {}
      
      add_price_filters
      add_category_filters
      add_brand_filters
      add_flag_filters
      add_stock_filters
      add_rating_filters
      add_attribute_filters
      add_search_filters
      add_sorting_filters
      add_status_filters
    end

    def add_price_filters
      @filters[:min_price] = @params[:min_price] if @params[:min_price].present?
      @filters[:max_price] = @params[:max_price] if @params[:max_price].present?
    end

    def add_category_filters
      @filters[:category_id] = @params[:category_id] if @params[:category_id].present?
      @filters[:category_slug] = @params[:category_slug] if @params[:category_slug].present?
      @filters[:category_ids] = @params[:category_ids] if @params[:category_ids].present?
    end

    def add_brand_filters
      @filters[:brand_id] = @params[:brand_id] if @params[:brand_id].present?
      @filters[:brand_slug] = @params[:brand_slug] if @params[:brand_slug].present?
      @filters[:brand_ids] = @params[:brand_ids] if @params[:brand_ids].present?
    end

    def add_flag_filters
      @filters[:featured] = @params[:featured] if @params[:featured].present?
      @filters[:bestseller] = @params[:bestseller] if @params[:bestseller].present?
      @filters[:new_arrival] = @params[:new_arrival] if @params[:new_arrival].present?
      @filters[:trending] = @params[:trending] if @params[:trending].present?
    end

    def add_stock_filters
      @filters[:in_stock] = @params[:in_stock] if @params[:in_stock].present?
    end

    def add_rating_filters
      @filters[:min_rating] = @params[:min_rating] if @params[:min_rating].present?
    end

    def add_attribute_filters
      @filters[:attribute_values] = @params[:attribute_values] if @params[:attribute_values].present?
    end

    def add_search_filters
      query = @params[:query] || @params[:search]
      @filters[:query] = query if query.present?
    end

    def add_sorting_filters
      @filters[:sort_by] = @params[:sort_by] if @params[:sort_by].present?
    end

    def add_status_filters
      @filters[:status] = @params[:status] if @params[:status].present?
    end
  end
end

