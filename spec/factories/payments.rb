FactoryBot.define do
  factory :payment do
    association :order
    association :user
    payment_id { "PAY-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}" }
    amount { 100.0 }
    currency { 'INR' }
    payment_method { 'credit_card' }
    payment_gateway { 'stripe' }
    status { 'pending' }
    
    trait :completed do
      status { 'completed' }
      paid_at { Time.current }
    end
    
    trait :failed do
      status { 'failed' }
    end
  end
end





