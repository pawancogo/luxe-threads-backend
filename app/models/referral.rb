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
  
  scope :pending, -> { where(status: 'pending') }
  scope :completed, -> { where(status: 'completed') }
  scope :rewarded, -> { where(status: 'rewarded') }
  scope :by_referrer, ->(user_id) { where(referrer_id: user_id) }
  scope :by_referred, ->(user_id) { where(referred_id: user_id) }
  
  # Mark as completed
  def mark_completed!
    update(status: 'completed', completed_at: Time.current)
  end
  
  # Mark as rewarded
  def mark_rewarded!
    update(status: 'rewarded')
  end
end

