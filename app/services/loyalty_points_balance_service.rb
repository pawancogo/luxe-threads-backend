# frozen_string_literal: true

# Service for calculating loyalty points balance
class LoyaltyPointsBalanceService < BaseService
  attr_reader :balance_data

  def initialize(user)
    super()
    @user = user
  end

  def call
    calculate_balance
    set_result(@balance_data)
    self
  rescue StandardError => e
    handle_error(e)
    self
  end

  private

  def calculate_balance
    transactions = @user.loyalty_points_transactions
    balance = transactions.sum(:points) || 0
    
    pending_expiry = transactions.where(transaction_type: 'earned')
                                 .where('expiry_date > ?', Date.current)
                                 .sum(:points) || 0
    
    @balance_data = {
      balance: balance,
      pending_expiry: pending_expiry,
      available_balance: balance
    }
  end
end

