FactoryBot.define do
  factory :email_template do
    template_type { 'welcome' }
    subject { 'Welcome to LuxeThreads' }
    body_html { '<p>Welcome {{name}}</p>' }
    body_text { 'Welcome {{name}}' }
    from_email { 'noreply@luxethreads.com' }
    from_name { 'LuxeThreads' }
    is_active { true }
  end
end

