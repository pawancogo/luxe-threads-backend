# frozen_string_literal: true

# Service for building admin user listing queries
# Extracts query building logic from controllers
module Admins
  class UserListingService < BaseService
    attr_reader :users

    def initialize(base_scope, params = {})
      super()
      @base_scope = base_scope
      @params = params
    end

    def call
      build_query
      apply_filters
      apply_pagination
      set_result(@users)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def build_query
      @users = @base_scope
    end

    def apply_filters
      @users = @users.by_email(@params[:email]) if @params[:email].present?
      @users = @users.search_by_name(@params[:search]) if @params[:search].present?
      @users = @users.by_role(@params[:role]) if @params[:role].present?
      @users = @users.with_active_status(@params[:active]) if @params[:active].present?
      @users = @users.order(created_at: :desc)
    end

    def apply_pagination
      page = (@params[:page] || 1).to_i
      per_page = (@params[:per_page] || 20).to_i
      @users = @users.page(page).per(per_page)
    end
  end
end

