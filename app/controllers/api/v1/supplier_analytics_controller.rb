# frozen_string_literal: true

class Api::V1::SupplierAnalyticsController < ApplicationController
  include ApiFormatters
  
  before_action :authorize_supplier!
  before_action :ensure_supplier_profile!

  # GET /api/v1/supplier/analytics
  def index
    supplier_profile = current_user.supplier_profile
    
    start_date = params[:start_date] ? Date.parse(params[:start_date]) : 30.days.ago.to_date
    end_date = params[:end_date] ? Date.parse(params[:end_date]) : Date.current
    
    # Validate date range
    if start_date > end_date
      render_validation_errors(['Start date must be before end date'], 'Invalid date range')
      return
    end
    
    # Limit to max 1 year
    if (end_date - start_date).to_i > 365
      render_validation_errors(['Date range cannot exceed 365 days'], 'Invalid date range')
      return
    end

    service = Suppliers::AnalyticsService.new(supplier_profile, start_date: start_date, end_date: end_date)
    analytics_data = service.call

    render_success(analytics_data, 'Analytics retrieved successfully')
  rescue Date::Error => e
    render_validation_errors(['Invalid date format'], 'Invalid date parameter')
  rescue StandardError => e
    Rails.logger.error "Error fetching analytics: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render_error('Failed to fetch analytics', 'Internal server error')
  end

  private

  def authorize_supplier!
    render_unauthorized('Not Authorized') unless current_user.supplier?
  end

  def ensure_supplier_profile!
    if current_user.supplier_profile.nil?
      render_validation_errors(
        ['Supplier profile not found. Please create a supplier profile first.'],
        'Supplier profile required'
      )
      return
    end
  end
end

