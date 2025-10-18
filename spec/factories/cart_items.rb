FactoryBot.define do
  factory :cart_item do
    association :cart
    association :product_variant
    quantity { Faker::Number.between(from: 1, to: 5) }
  end
end
