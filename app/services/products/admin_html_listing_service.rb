# frozen_string_literal: true

# Service for building admin HTML product listing queries
# Extracts query building logic from admin HTML controllers
module Products
  class AdminHtmlListingService < BaseService
    attr_reader :products, :filters

    def initialize(base_scope, params = {}, search_options = {})
      super()
      @base_scope = base_scope
      @params = params
      @search_options = search_options
    end

    def call
      build_query
      apply_status_filter
      apply_search
      apply_ordering
      merge_filters
      set_result(@products)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def build_query
      @products = @base_scope.admin_listing
    end

    def apply_status_filter
      status = @params[:status] || 'pending'
      @products = @products.with_status(status == 'all' ? nil : status)
    end

    def apply_search
      search_params = @params.except(:status).permit!
      @products = @products._search(search_params, **@search_options) if @products.respond_to?(:_search)
    end

    def apply_ordering
      @products = @products.order(created_at: :desc)
    end

    def merge_filters
      @filters = {}
      if @products.respond_to?(:filter_with_aggs)
        filter_aggs = @products.filter_with_aggs
        @filters.merge!(filter_aggs) if filter_aggs.present?
      end
    rescue => e
      Rails.logger.error "Error merging filters: #{e.message}"
      @filters = { search: [nil] }
    end
  end
end

