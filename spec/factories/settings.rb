FactoryBot.define do
  factory :setting do
    key { "setting_#{SecureRandom.hex(4)}" }
    value { 'test_value' }
    value_type { 'string' }
    category { 'general' }
    description { 'Test setting' }
    is_public { false }
    
    trait :public do
      is_public { true }
    end
    
    trait :boolean do
      value { 'true' }
      value_type { 'boolean' }
    end
    
    trait :integer do
      value { '100' }
      value_type { 'integer' }
    end
  end
end

