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
    @transactions = current_user.loyalty_points_transactions.order(created_at: :desc)
    
    # Filter by type
    @transactions = @transactions.where(transaction_type: params[:transaction_type]) if params[:transaction_type].present?
    
    render_success(format_transactions_data(@transactions), 'Loyalty points transactions retrieved successfully')
  end
  
  # GET /api/v1/loyalty_points/balance
  def balance
    # Calculate current balance
    balance = current_user.loyalty_points_transactions.sum(:points)
    
    # Get pending expiry count
    pending_expiry = current_user.loyalty_points_transactions
                                  .where(transaction_type: 'earned')
                                  .where('expiry_date > ?', Date.current)
                                  .sum(:points)
    
    render_success({
      balance: balance,
      pending_expiry: pending_expiry,
      available_balance: balance
    }, 'Loyalty points balance retrieved successfully')
  end
  
  private
  
  def format_transactions_data(transactions)
    transactions.map { |transaction| format_transaction_data(transaction) }
  end
  
  def format_transaction_data(transaction)
    {
      id: transaction.id,
      transaction_type: transaction.transaction_type,
      points: transaction.points,
      balance_after: transaction.balance_after,
      reference_type: transaction.reference_type,
      reference_id: transaction.reference_id,
      description: transaction.description,
      expiry_date: transaction.expiry_date,
      created_at: transaction.created_at
    }
  end
end

