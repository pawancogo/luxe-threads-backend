FactoryBot.define do
  factory :address do
    association :user
    address_type { "shipping" }
    full_name { Faker::Name.name }
    phone_number { Faker::PhoneNumber.phone_number }
    line1 { Faker::Address.street_address }
    line2 { Faker::Address.secondary_address }
    city { Faker::Address.city }
    state { Faker::Address.state }
    postal_code { Faker::Address.postcode }
    country { Faker::Address.country }
    
    trait :billing do
      address_type { "billing" }
    end
    
    trait :shipping do
      address_type { "shipping" }
    end
  end
end
