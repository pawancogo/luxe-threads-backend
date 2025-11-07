# frozen_string_literal: true

class CreateReferralsTable < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:referrals)
      create_table :referrals do |t|
        t.references :referrer, null: false, foreign_key: { to_table: :users }
        t.references :referred, null: false, foreign_key: { to_table: :users }
        
        # Referral Status
        t.string :status, limit: 50, null: false, default: 'pending'
        # Values: pending, completed, rewarded
        t.timestamp :completed_at
        
        # Rewards
        t.integer :referrer_reward_points, default: 0
        t.integer :referred_reward_points, default: 0
        t.boolean :referrer_reward_paid, default: false
        t.boolean :referred_reward_paid, default: false
        
        t.timestamps
      end
      
      # Add unique constraint and indexes
      add_index :referrals, [:referrer_id, :referred_id], unique: true unless index_exists?(:referrals, [:referrer_id, :referred_id])
      add_index :referrals, :status unless index_exists?(:referrals, :status)
    end
  end
end

