FactoryBot.define do
  factory :search_suggestion do
    query { 'test product' }
    suggestion_type { 'product' }
    is_active { true }
    search_count { 10 }
    click_count { 5 }
    
    trait :trending do
      suggestion_type { 'trending' }
    end
  end
end

