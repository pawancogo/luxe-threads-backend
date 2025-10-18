FactoryBot.define do
  factory :attribute_value do
    association :attribute_type
    value { Faker::Color.color_name }
  end
end
