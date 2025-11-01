#!/usr/bin/env ruby

# Script to generate secure secrets for LuxeThreads application
# Run this script to generate production-ready secrets

puts "🔐 LuxeThreads Secret Generator"
puts "=" * 50

# Generate Rails Secret Key Base
puts "\n1. Rails Secret Key Base:"
secret_key_base = `rails secret`.strip
puts secret_key_base

# Generate JWT Secret Key
puts "\n2. JWT Secret Key:"
jwt_secret = `openssl rand -hex 64`.strip
puts jwt_secret

# Generate random passwords
puts "\n3. Database Password (for production):"
db_password = `openssl rand -base64 32`.strip
puts db_password

puts "\n4. Redis Password (for production):"
redis_password = `openssl rand -base64 32`.strip
puts redis_password

puts "\n" + "=" * 50
puts "📋 Copy these values to your .env file:"
puts "=" * 50

puts "\n# Replace these in your .env file:"
puts "SECRET_KEY_BASE=#{secret_key_base}"
puts "JWT_SECRET_KEY=#{jwt_secret}"
puts "DATABASE_URL=postgresql://username:#{db_password}@localhost:5432/luxe_threads_production"
puts "REDIS_URL=redis://username:#{redis_password}@your-redis-host:6379/0"

puts "\n" + "=" * 50
puts "⚠️  IMPORTANT SECURITY NOTES:"
puts "=" * 50
puts "1. Keep these secrets secure and never commit them to version control"
puts "2. Use different secrets for development and production"
puts "3. Rotate secrets regularly in production"
puts "4. Store production secrets in a secure secret management system"
puts "5. Never share these secrets in plain text"

puts "\n" + "=" * 50
puts "🚀 Next Steps:"
puts "=" * 50
puts "1. Copy the generated values to your .env file"
puts "2. Configure your SMTP settings (Gmail, SendGrid, etc.)"
puts "3. Set up your database and Redis connections"
puts "4. Test the email verification system"
puts "5. Deploy to production with secure environment variables"

puts "\n✅ Secret generation complete!"



