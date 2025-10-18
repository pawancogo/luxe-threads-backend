
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
  end
end
