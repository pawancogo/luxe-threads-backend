source "http://rubygems.org"

ruby "3.3.6"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.1.6"

# Environment variables
gem "dotenv-rails", "~> 2.8"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use SQLite for development, PostgreSQL for production
gem "sqlite3", "~> 1.4", group: [:development, :test]
gem "pg", "~> 1.5", group: :production
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use argon2 for modern password hashing (compatible with Ruby 3.4+)
gem "argon2", "~> 2.2"

# For API development
gem "rack-cors"
gem "jwt"

# For rate limiting
gem "rack-attack"

# For Admin Interface and Authorization
gem "rails_admin"
gem "pundit"

# For audit logging and versioning
gem "paper_trail", "~> 14.0"

# For soft deletes
gem "paranoia", "~> 2.6"

# For Elasticsearch integration
gem "searchkick"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mswin jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mswin ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false


  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
  gem 'byebug'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  
  # RSpec for testing
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "shoulda-matchers"
  
  # Coverage
  gem "simplecov", require: false
  
  # Database cleaner
  gem "database_cleaner-active_record"
end

gem 'cloudinary'

gem 'stripe'
gem "sassc-rails"
gem 'prawn', '~> 2.4'
gem 'prawn-table', '~> 0.2'

# Bootstrap and jQuery for admin panel
gem 'bootstrap', '~> 5.3'
gem 'jquery-rails'

# Pagination for admin views
gem 'kaminari'
