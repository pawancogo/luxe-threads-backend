# frozen_string_literal: true

# Seed file for SystemConfiguration
# Run with: rails db:seed:system_configurations
# Or include in main seeds.rb

puts "Seeding System Configurations..."

# Get or create a system admin for seeding (optional - can be nil for system-created configs)
system_admin = Admin.find_by(role: 'super_admin') || Admin.first

# General System Configurations
SystemConfiguration.set('app_name', 'Luxe Threads', category: 'general', description: 'Application name', created_by: system_admin)
SystemConfiguration.set('app_version', '1.0.0', category: 'general', description: 'Application version', created_by: system_admin)
SystemConfiguration.set('maintenance_mode', false, value_type: 'boolean', category: 'general', description: 'Enable/disable maintenance mode', created_by: system_admin)

# Payment Configurations
SystemConfiguration.set('payment_gateway_enabled', true, value_type: 'boolean', category: 'payment', description: 'Enable payment gateway', created_by: system_admin)
SystemConfiguration.set('payment_timeout_minutes', 30, value_type: 'integer', category: 'payment', description: 'Payment timeout in minutes', created_by: system_admin)
SystemConfiguration.set('min_order_amount', 500.0, value_type: 'float', category: 'payment', description: 'Minimum order amount', created_by: system_admin)

# Shipping Configurations
SystemConfiguration.set('free_shipping_threshold', 2000.0, value_type: 'float', category: 'shipping', description: 'Free shipping threshold amount', created_by: system_admin)
SystemConfiguration.set('default_shipping_cost', 50.0, value_type: 'float', category: 'shipping', description: 'Default shipping cost', created_by: system_admin)
SystemConfiguration.set('shipping_enabled', true, value_type: 'boolean', category: 'shipping', description: 'Enable shipping', created_by: system_admin)

# Email Configurations
SystemConfiguration.set('email_from_address', 'noreply@luxethreads.com', category: 'email', description: 'Default from email address', created_by: system_admin)
SystemConfiguration.set('email_reply_to', 'support@luxethreads.com', category: 'email', description: 'Reply-to email address', created_by: system_admin)
SystemConfiguration.set('email_send_enabled', true, value_type: 'boolean', category: 'email', description: 'Enable email sending', created_by: system_admin)

# API Configurations
SystemConfiguration.set('api_rate_limit', 100, value_type: 'integer', category: 'api', description: 'API rate limit per minute', created_by: system_admin)
SystemConfiguration.set('api_timeout_seconds', 30, value_type: 'integer', category: 'api', description: 'API timeout in seconds', created_by: system_admin)
SystemConfiguration.set('api_version', 'v1', category: 'api', description: 'Current API version', created_by: system_admin)

# Feature Flags
SystemConfiguration.set('enable_reviews', true, value_type: 'boolean', category: 'feature_flags', description: 'Enable product reviews', created_by: system_admin)
SystemConfiguration.set('enable_wishlist', true, value_type: 'boolean', category: 'feature_flags', description: 'Enable wishlist feature', created_by: system_admin)
SystemConfiguration.set('enable_loyalty_points', true, value_type: 'boolean', category: 'feature_flags', description: 'Enable loyalty points', created_by: system_admin)
SystemConfiguration.set('enable_referrals', false, value_type: 'boolean', category: 'feature_flags', description: 'Enable referral program', created_by: system_admin)

# JSON Configuration Example
SystemConfiguration.set(
  'allowed_payment_methods',
  { credit_card: true, debit_card: true, upi: true, wallet: false },
  value_type: 'json',
  category: 'payment',
  description: 'Allowed payment methods configuration',
  created_by: system_admin
)

puts "✓ System Configurations seeded successfully!"
puts "Total configurations: #{SystemConfiguration.count}"

