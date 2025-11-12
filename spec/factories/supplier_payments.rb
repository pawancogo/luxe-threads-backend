FactoryBot.define do
  factory :supplier_payment do
    association :supplier_profile
    payment_id { "SUP-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}" }
    amount { 1000.0 }
    commission_deducted { 100.0 }
    net_amount { 900.0 }
    currency { 'INR' }
    payment_method { 'bank_transfer' }
    status { 'pending' }
    period_start_date { 30.days.ago }
    period_end_date { Date.current }
    
    trait :completed do
      status { 'completed' }
      processed_at { Time.current }
    end
  end
end





