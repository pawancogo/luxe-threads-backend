FactoryBot.define do
  factory :product_attribute do
    association :product
    association :attribute_value
  end
end





