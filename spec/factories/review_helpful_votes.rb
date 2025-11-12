FactoryBot.define do
  factory :review_helpful_vote do
    association :review
    association :user
    helpful { true }
  end
end





