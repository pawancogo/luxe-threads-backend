# frozen_string_literal: true

# Service for building loyalty points transaction listing queries
# Extracts query building logic from controllers
class LoyaltyPointsTransactionListingService < BaseService
  attr_reader :transactions

  def initialize(base_scope, params = {})
    super()
    @base_scope = base_scope
    @params = params
  end

  def call
    build_query
    apply_filters
    apply_ordering
    set_result(@transactions)
    self
  rescue StandardError => e
    handle_error(e)
    self
  end

  private

  def build_query
    @transactions = @base_scope
  end

  def apply_filters
    @transactions = @transactions.where(transaction_type: @params[:transaction_type]) if @params[:transaction_type].present?
  end

  def apply_ordering
    @transactions = @transactions.order(created_at: :desc)
  end
end

