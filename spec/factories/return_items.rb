FactoryBot.define do
  factory :return_item do
    association :return_request
    association :order_item
    quantity { Faker::Number.between(from: 1, to: 3) }
    reason { "defective" }
  end
end
