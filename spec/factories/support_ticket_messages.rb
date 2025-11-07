# frozen_string_literal: true

FactoryBot.define do
  factory :support_ticket_message do
    association :support_ticket, factory: :support_ticket
    message { Faker::Lorem.paragraph }
    sender_type { 'user' }
    sender_id { support_ticket.user_id }
    is_internal { false }
    is_read { false }
    attachments { [] }
    
    trait :internal do
      is_internal { true }
      sender_type { 'admin' }
      sender_id { create(:admin).id }
    end
    
    trait :read do
      is_read { true }
      read_at { Time.current }
    end
  end
end

