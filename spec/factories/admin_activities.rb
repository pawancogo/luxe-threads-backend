FactoryBot.define do
  factory :admin_activity do
    association :admin
    action { 'created' }
    resource_type { 'User' }
    resource_id { 1 }
    description { 'Created user' }
    changes { { 'name' => ['Old', 'New'] }.to_json }
    ip_address { '127.0.0.1' }
    user_agent { 'Test Agent' }
  end
end

