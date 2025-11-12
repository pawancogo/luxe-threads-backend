FactoryBot.define do
  factory :supplier do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    phone_number { Faker::PhoneNumber.phone_number }
    role { 'basic_supplier' }
    password { 'password123' }
    password_confirmation { 'password123' }
    
    trait :verified do
      role { 'verified_supplier' }
    end
    
    trait :premium do
      role { 'premium_supplier' }
    end
    
    trait :partner do
      role { 'partner_supplier' }
    end
  end
end





