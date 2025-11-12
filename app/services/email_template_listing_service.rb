# frozen_string_literal: true

# Service for building email template listing queries
# Extracts query building logic from controllers
class EmailTemplateListingService < BaseService
  attr_reader :templates

  def initialize(base_scope, params = {})
    super()
    @base_scope = base_scope
    @params = params
  end

  def call
    build_query
    apply_ordering
    set_result(@templates)
    self
  rescue StandardError => e
    handle_error(e)
    self
  end

  private

  def build_query
    @templates = @base_scope
  end

  def apply_ordering
    @templates = @templates.order(:template_type)
  end
end

