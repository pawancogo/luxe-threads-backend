FactoryBot.define do
  factory :supplier_profile do
    association :user, factory: [:user, :supplier]
    company_name { Faker::Company.name }
    gst_number { "GST#{Faker::Number.number(digits: 10)}" }
    description { Faker::Lorem.paragraph }
    website_url { Faker::Internet.url }
    verified { false }
  end
end
