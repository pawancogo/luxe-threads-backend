FactoryBot.define do
  factory :rbac_role_permission do
    association :rbac_role
    association :rbac_permission
  end
end





