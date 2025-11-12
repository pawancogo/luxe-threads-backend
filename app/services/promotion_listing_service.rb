# frozen_string_literal: true

# Service for building promotion listing queries
# Extracts query building logic from controllers
class PromotionListingService < BaseService
  attr_reader :promotions

  def initialize(base_scope, params = {})
    super()
    @base_scope = base_scope
    @params = params
  end

  def call
    build_query
    apply_filters
    apply_ordering
    set_result(@promotions)
    self
  rescue StandardError => e
    handle_error(e)
    self
  end

  private

  def build_query
    @promotions = @base_scope
  end

  def apply_filters
    @promotions = @promotions.where(promotion_type: @params[:promotion_type]) if @params[:promotion_type].present?
    @promotions = @promotions.featured if @params[:featured] == 'true'
    @promotions = @promotions.where(is_active: @params[:is_active] == 'true') if @params[:is_active].present?
  end

  def apply_ordering
    @promotions = @promotions.order(created_at: :desc)
  end
end

