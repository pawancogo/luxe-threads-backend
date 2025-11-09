FactoryBot.define do
  factory :email_verification do
    association :verifiable, factory: :user
    email { verifiable.email }
    otp { rand(100000..999999).to_s }
    verified_at { nil }
    
    trait :verified do
      verified_at { Time.current }
    end
    
    trait :expired do
      created_at { 20.minutes.ago }
    end
  end
end

