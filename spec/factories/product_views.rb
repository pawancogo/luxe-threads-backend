# frozen_string_literal: true

FactoryBot.define do
  factory :product_view do
    product
    user { nil } # Can be nil for anonymous views
    session_id { SecureRandom.hex(16) }
    ip_address { Faker::Internet.ip_v4_address }
    user_agent { Faker::Internet.user_agent }
    source { 'direct' }
    viewed_at { Time.current }
    
    trait :with_user do
      user
    end
    
    trait :with_variant do
      product_variant { create(:product_variant, product: product) }
    end
    
    trait :from_search do
      source { 'search' }
    end
  end
end

