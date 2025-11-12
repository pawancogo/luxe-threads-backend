# frozen_string_literal: true

class Api::V1::LoyaltyPointsController < ApplicationController
  # Phase 6: Feature flag check
  before_action :require_loyalty_points_feature!
  
  private
  
  def require_loyalty_points_feature!
    unless feature_enabled?(:loyalty_points)
      render_error('Loyalty points feature is not enabled', nil, :service_unavailable)
    end
  end
  
  public
  
  # GET /api/v1/loyalty_points
  def index
    base_scope = current_user.loyalty_points_transactions
    service = LoyaltyPointsTransactionListingService.new(base_scope, params)
    service.call
    
    if service.success?
      render_success(
        LoyaltyPointsTransactionSerializer.collection(service.transactions),
        'Loyalty points transactions retrieved successfully'
      )
    else
      render_validation_errors(service.errors, 'Failed to retrieve loyalty points transactions')
    end
  end

  # GET /api/v1/loyalty_points/balance
  def balance
    service = LoyaltyPointsBalanceService.new(current_user)
    service.call
    
    if service.success?
      render_success(service.balance_data, 'Loyalty points balance retrieved successfully')
    else
      render_error(service.errors.join(', '), :unprocessable_entity)
    end
  end
end

