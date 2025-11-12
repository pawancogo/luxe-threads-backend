FactoryBot.define do
  factory :coupon_usage do
    association :user
    association :coupon
    association :order
    discount_amount { 10.0 }
  end
end





