# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    user
    title { Faker::Lorem.sentence }
    message { Faker::Lorem.paragraph }
    notification_type { 'order_update' }
    is_read { false }
    read_at { nil }
    data { {} }
    sent_email { false }
    sent_sms { false }
    sent_push { false }
    
    trait :read do
      is_read { true }
      read_at { Time.current }
    end
    
    trait :order_update do
      notification_type { 'order_update' }
      title { 'Order Update' }
    end
    
    trait :promotion do
      notification_type { 'promotion' }
      title { 'New Promotion' }
    end
  end
end

