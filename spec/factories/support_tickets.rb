# frozen_string_literal: true

FactoryBot.define do
  factory :support_ticket do
    user
    ticket_id { "TKT-#{SecureRandom.hex(8).upcase}" }
    subject { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    category { 'other' }
    status { 'open' }
    priority { 'medium' }
    
    trait :order_issue do
      category { 'order_issue' }
      subject { 'Order Issue' }
    end
    
    trait :product_issue do
      category { 'product_issue' }
      subject { 'Product Issue' }
    end
    
    trait :resolved do
      status { 'resolved' }
      resolved_at { Time.current }
      resolution { 'Issue resolved' }
    end
    
    trait :high_priority do
      priority { 'high' }
    end
  end
end

