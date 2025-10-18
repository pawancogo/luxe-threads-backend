FactoryBot.define do
  factory :brand do
    name { Faker::Company.name }
  end
end
