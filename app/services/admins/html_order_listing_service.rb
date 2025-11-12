# frozen_string_literal: true

# Service for building admin HTML order listing queries
# Extracts query building logic from admin HTML controllers
module Admins
  class HtmlOrderListingService < BaseService
    attr_reader :orders, :filters

    def initialize(base_scope, params = {}, search_options = {})
      super()
      @base_scope = base_scope
      @params = params
      @search_options = search_options
    end

    def call
      build_query
      apply_search
      apply_ordering
      merge_filters
      set_result(@orders)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def build_query
      @orders = @base_scope.includes(:user)
    end

    def apply_search
      @orders = @orders._search(@params, **@search_options) if @orders.respond_to?(:_search)
    end

    def apply_ordering
      @orders = @orders.order(created_at: :desc)
    end

    def merge_filters
      @filters = {}
      if @orders.respond_to?(:filter_with_aggs)
        filter_aggs = @orders.filter_with_aggs
        @filters.merge!(filter_aggs) if filter_aggs.present?
      end
    rescue => e
      Rails.logger.error "Error merging filters: #{e.message}"
      @filters = { search: [nil] }
    end
  end
end

