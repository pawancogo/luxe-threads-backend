FactoryBot.define do
  factory :return_request do
    association :user
    association :order
    status { 0 }
    resolution_type { 0 }
  end
end
