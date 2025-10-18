FactoryBot.define do
  factory :product_image do
    association :product_variant
    image_url { Faker::Internet.url }
    alt_text { Faker::Lorem.sentence(word_count: 3) }
    display_order { Faker::Number.between(from: 1, to: 10) }
  end
end
