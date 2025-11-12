# frozen_string_literal: true

# Service for building review listing queries
# Extracts query building logic from controllers
class ReviewListingService < BaseService
  attr_reader :reviews

  def initialize(base_scope, params = {})
    super()
    @base_scope = base_scope
    @params = params
  end

  def call
    build_query
    apply_filters
    apply_ordering
    set_result(@reviews)
    self
  rescue StandardError => e
    handle_error(e)
    self
  end

  private

  def build_query
    @reviews = @base_scope
  end

  def apply_filters
    @reviews = @reviews.where(moderation_status: @params[:moderation_status]) if @params[:moderation_status].present?
    @reviews = @reviews.where(is_featured: true) if @params[:featured] == 'true'
    @reviews = @reviews.where(is_verified_purchase: true) if @params[:verified] == 'true'
  end

  def apply_ordering
    @reviews = @reviews.order(created_at: :desc)
  end
end

