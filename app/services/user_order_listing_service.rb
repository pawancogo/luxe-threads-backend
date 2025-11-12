# frozen_string_literal: true

# Service for building user order listing queries
# Extracts query building logic from controllers
class UserOrderListingService < BaseService
  attr_reader :orders

  def initialize(base_scope, params = {})
    super()
    @base_scope = base_scope
    @params = params
  end

  def call
    build_query
    apply_ordering
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

  def apply_ordering
    @orders = @orders.order(created_at: :desc)
  end

  def apply_pagination
    page = (@params[:page] || 1).to_i
    @orders = @orders.page(page)
  end
end

