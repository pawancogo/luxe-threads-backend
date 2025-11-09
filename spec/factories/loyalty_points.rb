FactoryBot.define do
  factory :loyalty_point do
    association :user
    points_balance { 100 }
    total_points_earned { 200 }
    total_points_redeemed { 100 }
  end
end

