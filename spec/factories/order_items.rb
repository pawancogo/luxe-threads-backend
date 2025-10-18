FactoryBot.define do
  factory :order_item do
    association :order
    association :product_variant
    quantity { Faker::Number.between(from: 1, to: 5) }
    price_at_purchase { Faker::Commerce.price(range: 50..500) }
  end
end
