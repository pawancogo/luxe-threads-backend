FactoryBot.define do
  factory :return_item do
    association :return_request
    association :order_item
    quantity { 1 }
    reason { 'defective' }
  end
end
