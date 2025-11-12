FactoryBot.define do
  factory :navigation_item do
    key { "nav_#{SecureRandom.hex(4)}" }
    label { 'Test Navigation' }
    path_method { 'root_path' }
    section { 'main' }
    display_order { 1 }
    is_active { true }
    always_visible { false }
    is_system { false }
    
    trait :system do
      is_system { true }
    end
    
    trait :always_visible do
      always_visible { true }
    end
  end
end





