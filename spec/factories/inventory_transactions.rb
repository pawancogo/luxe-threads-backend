FactoryBot.define do
  factory :inventory_transaction do
    association :product_variant
    association :supplier_profile
    transaction_type { 'purchase' }
    quantity { 10 }
    balance_before { 50 }
    balance_after { 60 }
    
    trait :sale do
      transaction_type { 'sale' }
      quantity { -5 }
      balance_after { 45 }
    end
  end
end





