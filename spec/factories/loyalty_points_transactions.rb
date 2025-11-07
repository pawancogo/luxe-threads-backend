# frozen_string_literal: true

FactoryBot.define do
  factory :loyalty_points_transaction do
    user
    transaction_type { 'earned' }
    points { 100 }
    balance_after { 100 }
    description { 'Points earned from order' }
    reference_type { 'Order' }
    reference_id { 1 }
    
    trait :earned do
      transaction_type { 'earned' }
      points { 100 }
    end
    
    trait :redeemed do
      transaction_type { 'redeemed' }
      points { -50 }
    end
    
    trait :expired do
      transaction_type { 'expired' }
      points { -10 }
      expiry_date { 1.day.ago }
    end
  end
end

