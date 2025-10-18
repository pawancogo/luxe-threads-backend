FactoryBot.define do
  factory :order do
    association :user
    association :shipping_address, factory: [:address, :shipping]
    association :billing_address, factory: [:address, :billing]
    status { "pending" }
    payment_status { "payment_pending" }
    shipping_method { "standard" }
    total_amount { Faker::Commerce.price(range: 100..1000) }
  end
end
