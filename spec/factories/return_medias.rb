FactoryBot.define do
  factory :return_media do
    association :return_item
    media_type { 'image' }
    media_url { Faker::Internet.url }
    
    trait :video do
      media_type { 'video' }
    end
    
    trait :document do
      media_type { 'document' }
    end
  end
end





