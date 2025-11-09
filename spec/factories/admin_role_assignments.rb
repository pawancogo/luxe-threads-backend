FactoryBot.define do
  factory :admin_role_assignment do
    association :admin
    association :rbac_role
    assigned_at { Time.current }
    
    trait :with_custom_permissions do
      custom_permissions { { 'products' => { 'create' => true } }.to_json }
    end
  end
end

