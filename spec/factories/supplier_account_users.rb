FactoryBot.define do
  factory :supplier_account_user do
    association :user
    association :supplier_profile
    role { 'staff' }
    status { 'active' }
    is_active { true }
    
    trait :owner do
      role { 'owner' }
    end
    
    trait :admin do
      role { 'admin' }
    end
    
    trait :pending do
      status { 'pending_invitation' }
      invitation_token { SecureRandom.urlsafe_base64(32) }
      invitation_expires_at { 7.days.from_now }
    end
  end
end





