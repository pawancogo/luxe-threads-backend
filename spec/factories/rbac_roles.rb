FactoryBot.define do
  factory :rbac_role do
    name { 'Test Role' }
    slug { "test_role_#{SecureRandom.hex(4)}" }
    role_type { 'admin' }
    description { 'Test role description' }
    priority { 1 }
    is_active { true }
    is_system { false }
    
    trait :system_role do
      is_system { true }
    end
    
    trait :supplier_role do
      role_type { 'supplier' }
      name { 'Supplier Manager' }
    end
  end
end





