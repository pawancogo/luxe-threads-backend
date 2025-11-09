FactoryBot.define do
  factory :referral do
    association :referrer, factory: :user
    association :referred, factory: :user
    status { 'pending' }
    
    trait :completed do
      status { 'completed' }
      completed_at { Time.current }
    end
    
    trait :rewarded do
      status { 'rewarded' }
    end
  end
end

