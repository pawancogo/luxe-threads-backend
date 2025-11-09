FactoryBot.define do
  factory :warehouse do
    association :supplier_profile
    name { 'Main Warehouse' }
    code { "WH#{SecureRandom.hex(4).upcase}" }
    address { '123 Warehouse St, Mumbai' }
    is_active { true }
    is_primary { false }
    
    trait :primary do
      is_primary { true }
    end
  end
end

