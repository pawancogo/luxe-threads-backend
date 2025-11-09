FactoryBot.define do
  factory :promotion do
    name { 'Test Promotion' }
    promotion_type { 'flash_sale' }
    start_date { 1.day.ago }
    end_date { 30.days.from_now }
    is_active { true }
    is_featured { false }
    
    trait :featured do
      is_featured { true }
    end
    
    trait :expired do
      start_date { 30.days.ago }
      end_date { 1.day.ago }
    end
  end
end

