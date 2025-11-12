FactoryBot.define do
  factory :supplier_analytic do
    association :supplier_profile
    date { Date.current }
    total_orders { 10 }
    total_revenue { 1000.0 }
    products_viewed { 100 }
    products_added_to_cart { 25 }
    conversion_rate { 25.0 }
  end
end





