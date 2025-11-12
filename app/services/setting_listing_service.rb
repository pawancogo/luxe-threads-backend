# frozen_string_literal: true

# Service for building setting listing queries
# Extracts query building logic from controllers
class SettingListingService < BaseService
  attr_reader :settings

  def initialize(base_scope, params = {})
    super()
    @base_scope = base_scope
    @params = params
  end

  def call
    build_query
    apply_filters
    apply_ordering
    set_result(@settings)
    self
  rescue StandardError => e
    handle_error(e)
    self
  end

  private

  def build_query
    @settings = @base_scope
  end

  def apply_filters
    @settings = @settings.by_category(@params[:category]) if @params[:category].present?
  end

  def apply_ordering
    @settings = @settings.order(:category, :key)
  end
end

