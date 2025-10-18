FactoryBot.define do
  factory :return_media do
    association :return_item
    media_url { Faker::Internet.url }
    media_type { "image" }
    
    trait :video do
      media_type { "video" }
    end
  end
end
