FactoryBot.define do
  factory :review do
    association :user
    association :product
    rating { Faker::Number.between(from: 1, to: 5) }
    comment { Faker::Lorem.paragraph }
    verified_purchase { true }
    
    trait :unverified do
      verified_purchase { false }
    end
  end
end
