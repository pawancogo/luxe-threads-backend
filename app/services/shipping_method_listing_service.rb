# frozen_string_literal: true

# Service for building shipping method listing queries
# Extracts query building logic from controllers
class ShippingMethodListingService < BaseService
  attr_reader :shipping_methods

  def initialize(base_scope, params = {})
    super()
    @base_scope = base_scope
    @params = params
  end

  def call
    build_query
    apply_filters
    apply_ordering
    set_result(@shipping_methods)
    self
  rescue StandardError => e
    handle_error(e)
    self
  end

  private

  def build_query
    @shipping_methods = @base_scope
  end

  def apply_filters
    @shipping_methods = @shipping_methods.where(is_active: @params[:is_active] == 'true') if @params[:is_active].present?
  end

  def apply_ordering
    @shipping_methods = @shipping_methods.order(:name)
  end
end

