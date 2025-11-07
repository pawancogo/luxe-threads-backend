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
  end
end

