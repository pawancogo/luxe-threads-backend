FactoryBot.define do
  factory :payment_refund do
    association :payment
    association :order
    refund_id { "REF-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}" }
    amount { 100.0 }
    currency { 'INR' }
    reason { 'Customer request' }
    status { 'pending' }
    
    trait :completed do
      status { 'completed' }
      processed_at { Time.current }
    end
  end
end

