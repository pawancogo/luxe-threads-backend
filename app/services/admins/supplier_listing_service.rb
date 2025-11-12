# frozen_string_literal: true

# Service for building admin supplier listing queries
# Extracts query building logic from controllers
module Admins
  class SupplierListingService < BaseService
    attr_reader :suppliers

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
      set_result(@suppliers)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def build_query
      @suppliers = @base_scope
    end

    def apply_filters
      @suppliers = @suppliers.search_by_company_name(@params[:search]) if @params[:search].present?
      @suppliers = @suppliers.by_email(@params[:email]) if @params[:email].present?
      @suppliers = @suppliers.with_verified_supplier_profile(@params[:verified]) if @params[:verified].present?
      @suppliers = @suppliers.with_active_status(@params[:active]) if @params[:active].present?
    end

    def apply_ordering
      @suppliers = @suppliers.order(created_at: :desc)
    end

    def apply_pagination
      page = (@params[:page] || 1).to_i
      per_page = (@params[:per_page] || 20).to_i
      @suppliers = @suppliers.page(page).per(per_page)
    end
  end
end

