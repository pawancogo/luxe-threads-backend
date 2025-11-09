FactoryBot.define do
  factory :attribute_value do
    association :attribute_type
    value { Faker::Commerce.color }
    
    trait :size do
      association :attribute_type, factory: [:attribute_type, :size]
      value { %w[XS S M L XL XXL].sample }
    end
    
    trait :color do
      association :attribute_type, factory: [:attribute_type, :color]
      value { Faker::Color.color_name }
    end
  end
end
