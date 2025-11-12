FactoryBot.define do
  factory :notification_preference do
    association :user
    preferences { {
      'email' => {
        'order_updates' => true,
        'promotions' => true
      },
      'sms' => {
        'order_updates' => true,
        'promotions' => false
      }
    }.to_json }
  end
end





