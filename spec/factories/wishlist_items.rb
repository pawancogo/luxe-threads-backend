FactoryBot.define do
  factory :wishlist_item do
    association :wishlist
    association :product_variant
  end
end
