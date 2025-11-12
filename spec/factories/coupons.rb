FactoryBot.define do
  factory :coupon do
    code { "COUPON#{SecureRandom.hex(4).upcase}" }
    name { 'Test Coupon' }
    coupon_type { 'percentage' }
    discount_value { 10 }
    valid_from { 1.day.ago }
    valid_until { 30.days.from_now }
    is_active { true }
    max_uses { 100 }
    current_uses { 0 }
    
    trait :fixed_amount do
      coupon_type { 'fixed_amount' }
      discount_value { 50 }
    end
    
    trait :expired do
      valid_from { 30.days.ago }
      valid_until { 1.day.ago }
    end
  end
end





