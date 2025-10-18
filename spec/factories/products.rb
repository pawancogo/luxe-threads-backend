FactoryBot.define do
  factory :product do
    association :category
    association :brand
    association :supplier_profile
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph }
    status { "pending" }
    
    trait :active do
      status { "active" }
    end
    
    trait :rejected do
      status { "rejected" }
    end
    
    trait :archived do
      status { "archived" }
    end
  end
end
