
FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { "password123" }
    password_confirmation { "password123" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    phone_number { Faker::PhoneNumber.phone_number }
    role { "customer" }
    
    trait :supplier do
      role { "supplier" }
    end
    
    trait :admin do
      role { "super_admin" }
    end
    
    trait :pending_invitation do
      first_name { nil }
      last_name { nil }
      phone_number { nil }
      password { nil }
      password_confirmation { nil }
      invitation_status { 'pending' }
      invitation_token { SecureRandom.urlsafe_base64(32) }
      invitation_sent_at { Time.current }
      invitation_expires_at { 7.days.from_now }
      is_active { false }
    end
    
    trait :with_invitation_role do
      invitation_role { 'supplier' }
    end
  end
end
