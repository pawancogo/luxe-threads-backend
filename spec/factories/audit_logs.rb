FactoryBot.define do
  factory :audit_log do
    association :user, optional: true
    auditable_type { 'User' }
    auditable_id { 1 }
    action { 'created' }
    changes { { 'name' => ['Old', 'New'] }.to_json }
    ip_address { '127.0.0.1' }
    user_agent { 'Test Agent' }
  end
end

