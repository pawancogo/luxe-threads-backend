# frozen_string_literal: true

FactoryBot.define do
  factory :admin do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.unique.email }
    phone_number { Faker::PhoneNumber.phone_number }
    role { 'super_admin' }
    password { 'Test@123456' }
    password_confirmation { 'Test@123456' }
    
    trait :product_admin do
      role { 'product_admin' }
    end
    
    trait :order_admin do
      role { 'order_admin' }
    end
    
    trait :supplier_admin do
      role { 'supplier_admin' }
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
  end
end

