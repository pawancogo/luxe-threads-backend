FactoryBot.define do
  factory :support_ticket_message do
    association :support_ticket
    association :user
    message { Faker::Lorem.paragraph }
    message_type { 'user_message' }
    
    trait :admin_message do
      association :admin
      message_type { 'admin_message' }
    end
    
    trait :system_message do
      message_type { 'system_message' }
    end
  end
end
