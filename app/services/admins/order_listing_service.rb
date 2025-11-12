# frozen_string_literal: true

# Service for building admin order listing queries
# Extracts query building logic from controllers
module Admins
  class OrderListingService < BaseService
    attr_reader :orders

    def initialize(base_scope, params = {})
      super()
      @base_scope = base_scope
      @params = params
    end

    def call
      build_query
      apply_filters
      apply_pagination
      set_result(@orders)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def build_query
      @orders = @base_scope
    end

    def apply_filters
      @orders = @orders.with_status(@params[:status]) if @params[:status].present?
      @orders = @orders.with_payment_status(@params[:payment_status]) if @params[:payment_status].present?
      @orders = @orders.for_user(@params[:user_id]) if @params[:user_id].present?
      @orders = @orders.search_by_order_number(@params[:order_number]) if @params[:order_number].present?
      @orders = @orders.created_between(@params[:created_from], @params[:created_to])
      @orders = @orders.amount_between(@params[:min_amount], @params[:max_amount])
      @orders = @orders.order(created_at: :desc)
    end

    def apply_pagination
      page = (@params[:page] || 1).to_i
      per_page = (@params[:per_page] || 20).to_i
      @orders = @orders.page(page).per(per_page)
    end
  end
end

