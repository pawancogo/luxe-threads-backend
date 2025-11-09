FactoryBot.define do
  factory :rbac_permission do
    name { 'Create Products' }
    slug { "products:create_#{SecureRandom.hex(4)}" }
    resource_type { 'products' }
    action { 'create' }
    category { 'products' }
    description { 'Permission to create products' }
    is_active { true }
    is_system { false }
    
    trait :system_permission do
      is_system { true }
    end
  end
end

