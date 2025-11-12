# frozen_string_literal: true

class Referral < ApplicationRecord
  belongs_to :referrer, class_name: 'User', foreign_key: 'referrer_id'
  belongs_to :referred, class_name: 'User', foreign_key: 'referred_id'
  
  # Status
  enum :status, {
    pending: 'pending',
    completed: 'completed',
    rewarded: 'rewarded'
  }, default: 'pending'
  
  validates :referrer_id, uniqueness: { scope: :referred_id }
  validates :status, presence: true
  
  # Ecommerce-specific scopes
  scope :pending, -> { where(status: 'pending') }
  scope :completed, -> { where(status: 'completed') }
  scope :rewarded, -> { where(status: 'rewarded') }
  scope :by_referrer, ->(referrer_id) { where(referrer_id: referrer_id) }
  scope :by_referred_customer, ->(referred_id) { where(referred_id: referred_id) }
  scope :for_customer, ->(customer_id) { where(referrer_id: customer_id) }
  scope :with_referred_customer, -> { includes(:referred) }
  
  # Mark as completed
  def mark_completed!
    update(status: 'completed', completed_at: Time.current)
  end
  
  # Mark as rewarded
  def mark_rewarded!
    update(status: 'rewarded')
  end
end

