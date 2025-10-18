FactoryBot.define do
  factory :product_variant_attribute do
    association :product_variant
    association :attribute_value
  end
end
