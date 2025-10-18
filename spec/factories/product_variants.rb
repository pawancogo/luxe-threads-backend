FactoryBot.define do
  factory :product_variant do
    association :product
    sku { Faker::Alphanumeric.alphanumeric(number: 10).upcase }
    price { Faker::Commerce.price(range: 100..1000) }
    discounted_price { Faker::Commerce.price(range: 50..500) }
    stock_quantity { Faker::Number.between(from: 0, to: 100) }
    weight_kg { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
  end
end
