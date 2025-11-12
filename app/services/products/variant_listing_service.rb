# frozen_string_literal: true

# Service for building product variant listing queries
# Extracts query building logic from controllers
module Products
  class VariantListingService < BaseService
    attr_reader :variants

    def initialize(base_scope, params = {})
      super()
      @base_scope = base_scope
      @params = params
    end

    def call
      build_query
      apply_filters
      apply_ordering
      apply_pagination
      set_result(@variants)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def build_query
      @variants = @base_scope.with_full_details
    end

    def apply_filters
      @variants = @variants.search_by_sku(@params[:variant_search]) if @params[:variant_search].present?
      @variants = @variants.apply_variant_status_filter(@params[:variant_status]) if @params[:variant_status].present?
    end

    def apply_ordering
      @variants = @variants.order(created_at: :desc)
    end

    def apply_pagination
      page = (@params[:variant_page] || 1).to_i
      @variants = @variants.page(page)
    end
  end
end

