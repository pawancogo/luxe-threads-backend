# frozen_string_literal: true

# Service for building admin admin listing queries
# Extracts query building logic from controllers
module Admins
  class AdminListingService < BaseService
    attr_reader :admins

    def initialize(base_scope, params = {})
      super()
      @base_scope = base_scope
      @params = params
    end

    def call
      build_query
      apply_search
      apply_ordering
      apply_pagination
      set_result(@admins)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def build_query
      @admins = @base_scope
    end

    def apply_search
      search_params = @params.except(:controller, :action, :per_page, :page).permit(:search, :role, :is_active, :is_blocked)
      @admins = @admins._search(search_params) if search_params.present?
    end

    def apply_ordering
      @admins = @admins.order(:role, :first_name)
    end

    def apply_pagination
      page = (@params[:page]&.to_i || 1)
      per_page = (@params[:per_page]&.to_i || 20)
      @admins = @admins.page(page).per(per_page)
    end
  end
end

