FactoryBot.define do
  factory :shipping_method do
    name { 'Standard Shipping' }
    code { "STD#{SecureRandom.hex(2).upcase}" }
    description { 'Standard shipping method' }
    base_cost { 50.0 }
    is_active { true }
    is_cod_available { true }
    estimated_days { 5 }
    
    trait :express do
      name { 'Express Shipping' }
      base_cost { 100.0 }
      estimated_days { 2 }
    end
  end
end





