# frozen_string_literal: true

class LoyaltyPointsTransaction < ApplicationRecord
  self.table_name = 'loyalty_points_transactions'
  
  belongs_to :user
  
  # Transaction types
  enum :transaction_type, {
    earned: 'earned',
    redeemed: 'redeemed',
    expired: 'expired',
    adjusted: 'adjusted'
  }
  
  validates :transaction_type, presence: true
  validates :points, presence: true, numericality: { other_than: 0 }
  validates :balance_after, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  scope :recent, -> { order(created_at: :desc) }
  scope :earned, -> { where(transaction_type: 'earned') }
  scope :redeemed, -> { where(transaction_type: 'redeemed') }
  scope :expired, -> { where(transaction_type: 'expired') }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  
  # Check if points are expired
  def expired?
    return false unless expiry_date.present?
    expiry_date < Date.current
  end
end

