FactoryBot.define do
  factory :trending_product do
    association :product
    calculated_at { Time.current }
    views_24h { 100 }
    orders_24h { 10 }
    revenue_24h { 500.0 }
    trend_score { 150.0 }
  end
end





