FactoryBot.define do
  factory :version do
    item_type { 'Product' }
    item_id { 1 }
    event { 'update' }
    whodunnit { 'User:1' }
    object { nil }
    object_changes { nil }
    created_at { Time.current }
    
    trait :create_event do
      event { 'create' }
    end
    
    trait :destroy_event do
      event { 'destroy' }
    end
    
    trait :by_admin do
      whodunnit { 'Admin:1' }
    end
    
    trait :by_supplier do
      whodunnit { 'Supplier:1' }
    end
  end
end





