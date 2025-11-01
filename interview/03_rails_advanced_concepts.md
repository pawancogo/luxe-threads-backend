# Advanced Rails Concepts Guide

## Table of Contents
1. [Rails Architecture & Internals](#rails-architecture--internals)
2. [Active Record Advanced Features](#active-record-advanced-features)
3. [Rails Performance Optimization](#rails-performance-optimization)
4. [Background Jobs & Processing](#background-jobs--processing)
5. [Rails Security](#rails-security)
6. [Testing Strategies](#testing-strategies)
7. [Rails Deployment & DevOps](#rails-deployment--devops)
8. [Common Interview Questions](#common-interview-questions)

## Rails Architecture & Internals

### Rails Application Structure
```
app/
├── controllers/          # Request handling
├── models/              # Business logic & data
├── views/               # Presentation layer
├── helpers/             # View helpers
├── mailers/             # Email handling
├── jobs/                # Background jobs
├── services/            # Business services
├── policies/            # Authorization
└── concerns/            # Shared modules

config/
├── routes.rb            # URL routing
├── application.rb       # App configuration
├── environments/        # Environment configs
└── initializers/        # Startup configuration

db/
├── migrate/             # Database migrations
├── schema.rb            # Current schema
└── seeds.rb             # Seed data
```

### Rails Request Lifecycle
```
1. Request → Router → Controller
2. Controller → Model → Database
3. Model → Controller → View
4. View → Response → Client
```

**Detailed Flow:**
```ruby
# 1. Routing
Rails.application.routes.draw do
  resources :users
end

# 2. Controller Action
class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])  # Model interaction
    respond_to do |format|
      format.html { render :show }  # View rendering
      format.json { render json: @user }
    end
  end
end

# 3. Model
class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  has_many :orders
end

# 4. View
# app/views/users/show.html.erb
<h1><%= @user.name %></h1>
```

### Rails Middleware Stack
```ruby
# config/application.rb
config.middleware.use CustomMiddleware

# Custom middleware example
class CustomMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    # Before request processing
    start_time = Time.current
    
    status, headers, response = @app.call(env)
    
    # After request processing
    duration = Time.current - start_time
    Rails.logger.info "Request completed in #{duration}ms"
    
    [status, headers, response]
  end
end
```

### Autoloading & Eager Loading
```ruby
# config/application.rb
config.autoload_paths += %W(#{config.root}/lib)
config.eager_load_paths += %W(#{config.root}/lib)

# Custom autoloader
class CustomAutoloader < Zeitwerk::Loader
  def setup
    push_dir(Rails.root.join('app', 'services'))
    inflector.inflect('api' => 'API')
  end
end
```

## Active Record Advanced Features

### Advanced Associations

#### Polymorphic Associations
```ruby
# Models
class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
end

class Post < ApplicationRecord
  has_many :comments, as: :commentable
end

class Photo < ApplicationRecord
  has_many :comments, as: :commentable
end

# Usage
post = Post.find(1)
post.comments.create(content: "Great post!")

photo = Photo.find(1)
photo.comments.create(content: "Nice photo!")
```

#### Self-Referential Associations
```ruby
class Category < ApplicationRecord
  belongs_to :parent, class_name: 'Category', optional: true
  has_many :children, class_name: 'Category', foreign_key: 'parent_id'
  
  # Find root categories
  scope :roots, -> { where(parent_id: nil) }
  
  # Find leaf categories
  scope :leaves, -> { left_joins(:children).where(categories: { id: nil }) }
end
```

#### Through Associations
```ruby
class User < ApplicationRecord
  has_many :user_roles
  has_many :roles, through: :user_roles
  has_many :permissions, through: :roles
end

class Role < ApplicationRecord
  has_many :user_roles
  has_many :users, through: :user_roles
  has_many :role_permissions
  has_many :permissions, through: :role_permissions
end
```

### Advanced Queries

#### Scopes and Query Methods
```ruby
class User < ApplicationRecord
  # Scopes
  scope :active, -> { where(active: true) }
  scope :recent, -> { where('created_at > ?', 1.week.ago) }
  scope :by_role, ->(role) { joins(:roles).where(roles: { name: role }) }
  
  # Dynamic scopes
  scope :created_between, ->(start_date, end_date) {
    where(created_at: start_date..end_date)
  }
  
  # Class methods
  def self.search(query)
    where("first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ?", 
          "%#{query}%", "%#{query}%", "%#{query}%")
  end
  
  def self.top_customers(limit = 10)
    joins(:orders)
      .group('users.id')
      .order('SUM(orders.total_amount) DESC')
      .limit(limit)
  end
end
```

#### Complex Joins and Includes
```ruby
# N+1 Query Problem
users = User.all
users.each { |user| puts user.orders.count }  # N+1 queries

# Solution 1: includes (LEFT OUTER JOIN)
users = User.includes(:orders)
users.each { |user| puts user.orders.count }  # 2 queries total

# Solution 2: preload (separate queries)
users = User.preload(:orders)
users.each { |user| puts user.orders.count }  # 2 queries total

# Solution 3: eager_load (LEFT OUTER JOIN)
users = User.eager_load(:orders)
users.each { |user| puts user.orders.count }  # 1 query with JOIN

# Complex includes
users = User.includes(orders: [:order_items, :products])
```

#### Raw SQL and Arel
```ruby
# Raw SQL
User.find_by_sql("SELECT * FROM users WHERE created_at > ?", 1.week.ago)

# Arel for complex queries
users = User.arel_table
orders = Order.arel_table

query = users
  .join(orders)
  .on(users[:id].eq(orders[:user_id]))
  .where(orders[:total_amount].gt(100))
  .project(users[:id], users[:email], orders[:total_amount].sum.as('total_spent'))
  .group(users[:id], users[:email])

User.find_by_sql(query.to_sql)
```

### Advanced Validations

#### Custom Validators
```ruby
class EmailDomainValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    
    domain = value.split('@').last
    allowed_domains = options[:domains] || ['gmail.com', 'yahoo.com']
    
    unless allowed_domains.include?(domain)
      record.errors.add(attribute, "must be from allowed domains: #{allowed_domains.join(', ')}")
    end
  end
end

class User < ApplicationRecord
  validates :email, email_domain: { domains: ['company.com', 'partner.com'] }
end
```

#### Conditional Validations
```ruby
class User < ApplicationRecord
  validates :email, presence: true, if: :email_required?
  validates :phone, presence: true, unless: :email_present?
  validates :password, confirmation: true, if: :password_changed?
  
  private
  
  def email_required?
    registration_method == 'email'
  end
  
  def email_present?
    email.present?
  end
  
  def password_changed?
    password.present? || password_confirmation.present?
  end
end
```

### Callbacks and Lifecycle

#### Advanced Callbacks
```ruby
class User < ApplicationRecord
  # Callback chains
  before_validation :normalize_email
  after_validation :log_validation_errors
  before_save :encrypt_password
  after_save :send_welcome_email
  after_commit :update_search_index, on: [:create, :update]
  after_rollback :log_rollback
  
  # Conditional callbacks
  before_save :update_last_login, if: :will_save_change_to_last_login_at?
  after_destroy :cleanup_associated_data, unless: :skip_cleanup?
  
  # Callback with options
  before_save :generate_api_key, if: -> { new_record? && api_key.blank? }
  
  private
  
  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
  
  def log_validation_errors
    Rails.logger.warn "Validation errors: #{errors.full_messages}" if errors.any?
  end
  
  def encrypt_password
    self.password_digest = BCrypt::Password.create(password) if password.present?
  end
  
  def send_welcome_email
    UserMailer.welcome(self).deliver_later
  end
  
  def update_search_index
    SearchIndexJob.perform_later(self)
  end
end
```

#### Transaction Callbacks
```ruby
class Order < ApplicationRecord
  after_commit :send_confirmation_email, on: :create
  after_commit :update_inventory, on: [:create, :update]
  after_rollback :restore_inventory, on: :create
  
  private
  
  def send_confirmation_email
    OrderMailer.confirmation(self).deliver_later
  end
  
  def update_inventory
    order_items.each do |item|
      item.product.decrement!(:stock_quantity, item.quantity)
    end
  end
  
  def restore_inventory
    order_items.each do |item|
      item.product.increment!(:stock_quantity, item.quantity)
    end
  end
end
```

## Rails Performance Optimization

### Database Optimization

#### Query Optimization
```ruby
# Bad: N+1 queries
users = User.all
users.each { |user| puts user.orders.count }

# Good: Use includes
users = User.includes(:orders)
users.each { |user| puts user.orders.count }

# Better: Use counter cache
class User < ApplicationRecord
  has_many :orders
end

class Order < ApplicationRecord
  belongs_to :user, counter_cache: true
end

# Migration to add counter cache
class AddOrdersCountToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :orders_count, :integer, default: 0
    User.reset_counters(User.ids, :orders)
  end
end
```

#### Database Indexing
```ruby
# Add indexes for frequently queried columns
class AddIndexesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :email, unique: true
    add_index :users, [:first_name, :last_name]
    add_index :users, :created_at
    add_index :orders, [:user_id, :created_at]
  end
end

# Partial indexes
add_index :users, :email, where: "active = true"
add_index :orders, :status, where: "status IN ('pending', 'processing')"
```

#### Connection Pooling
```ruby
# config/database.yml
production:
  adapter: postgresql
  database: myapp_production
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000
  checkout_timeout: 5
  reaping_frequency: 10
```

### Caching Strategies

#### Fragment Caching
```erb
<!-- app/views/users/index.html.erb -->
<% cache("users_index_#{User.maximum(:updated_at)}") do %>
  <h1>All Users</h1>
  <% @users.each do |user| %>
    <% cache(user) do %>
      <div class="user">
        <h3><%= user.name %></h3>
        <p><%= user.email %></p>
      </div>
    <% end %>
  <% end %>
<% end %>
```

#### Russian Doll Caching
```erb
<!-- Parent cache key includes child cache keys -->
<% cache("users_#{@users.maximum(:updated_at)}_#{@users.count}") do %>
  <% @users.each do |user| %>
    <% cache(user) do %>
      <!-- User content -->
    <% end %>
  <% end %>
<% end %>
```

#### Low-Level Caching
```ruby
class User < ApplicationRecord
  def expensive_calculation
    Rails.cache.fetch("user_#{id}_expensive_calculation", expires_in: 1.hour) do
      # Expensive operation
      calculate_user_metrics
    end
  end
  
  def self.top_users
    Rails.cache.fetch("top_users", expires_in: 30.minutes) do
      joins(:orders)
        .group('users.id')
        .order('SUM(orders.total_amount) DESC')
        .limit(10)
    end
  end
end
```

#### Cache Invalidation
```ruby
class User < ApplicationRecord
  after_update :clear_cache
  
  private
  
  def clear_cache
    Rails.cache.delete("user_#{id}_expensive_calculation")
    Rails.cache.delete("top_users")
  end
end
```

### Memory Optimization

#### Object Allocation Tracking
```ruby
# Gemfile
gem 'memory_profiler'
gem 'stackprof'

# Usage
require 'memory_profiler'

report = MemoryProfiler.report do
  User.includes(:orders).limit(1000).each do |user|
    user.orders.sum(:total_amount)
  end
end

report.pretty_print
```

#### Lazy Loading
```ruby
# Use lazy enumerators for large datasets
User.find_each(batch_size: 1000) do |user|
  process_user(user)
end

# Use find_in_batches for processing
User.find_in_batches(batch_size: 1000) do |batch|
  batch.each { |user| process_user(user) }
end
```

## Background Jobs & Processing

### Sidekiq Integration
```ruby
# Gemfile
gem 'sidekiq'
gem 'sidekiq-cron'

# config/initializers/sidekiq.rb
Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] }
end

# Job class
class EmailNotificationJob < ApplicationJob
  queue_as :default
  
  def perform(user_id, message)
    user = User.find(user_id)
    UserMailer.notification(user, message).deliver_now
  end
end

# Usage
EmailNotificationJob.perform_later(user.id, "Welcome!")
```

### Advanced Job Patterns

#### Job Chaining
```ruby
class OrderProcessingJob < ApplicationJob
  def perform(order_id)
    order = Order.find(order_id)
    
    # Process order
    process_order(order)
    
    # Chain next job
    InventoryUpdateJob.perform_later(order.id)
    EmailConfirmationJob.perform_later(order.id)
  end
end
```

#### Job Scheduling
```ruby
# config/schedule.rb (when-cron gem)
every 1.day, at: '4:30 am' do
  runner "DailyReportJob.perform_later"
end

every 1.hour do
  runner "CleanupJob.perform_later"
end

# Sidekiq-cron
Sidekiq::Cron::Job.create(
  name: 'Daily Report',
  cron: '0 4 * * *',
  class: 'DailyReportJob'
)
```

#### Job Monitoring
```ruby
# config/routes.rb
require 'sidekiq/web'
mount Sidekiq::Web => '/sidekiq'

# Custom monitoring
class ApplicationJob < ActiveJob::Base
  rescue_from StandardError do |exception|
    Rails.logger.error "Job failed: #{exception.message}"
    # Send to error tracking service
    ErrorTracker.notify(exception)
  end
end
```

## Rails Security

### Authentication & Authorization

#### Devise Integration
```ruby
# Gemfile
gem 'devise'
gem 'devise-jwt'

# User model
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable, :trackable
end

# JWT configuration
class ApplicationController < ActionController::API
  before_action :authenticate_user!
end
```

#### Custom Authorization
```ruby
# app/policies/application_policy.rb
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def update?
    false
  end

  def destroy?
    false
  end
end

# app/policies/user_policy.rb
class UserPolicy < ApplicationPolicy
  def show?
    user.admin? || user == record
  end

  def update?
    user.admin? || user == record
  end

  def destroy?
    user.admin?
  end
end

# Controller usage
class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    authorize @user
  end
end
```

### Security Best Practices

#### CSRF Protection
```ruby
# config/application.rb
config.force_ssl = true

# Controller
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  # For API controllers
  skip_before_action :verify_authenticity_token, if: :api_request?
  
  private
  
  def api_request?
    request.format.json?
  end
end
```

#### SQL Injection Prevention
```ruby
# Bad: SQL injection vulnerable
User.where("name = '#{params[:name]}'")

# Good: Parameterized queries
User.where("name = ?", params[:name])
User.where(name: params[:name])

# Good: Using Arel
users = User.arel_table
User.where(users[:name].eq(params[:name]))
```

#### XSS Protection
```ruby
# Automatic HTML escaping in views
<%= @user.bio %>  # Automatically escaped

# Safe HTML (use with caution)
<%= raw @user.bio %>  # Not escaped
<%= @user.bio.html_safe %>  # Not escaped

# Sanitize user input
class User < ApplicationRecord
  before_save :sanitize_bio
  
  private
  
  def sanitize_bio
    self.bio = ActionController::Base.helpers.sanitize(bio)
  end
end
```

## Testing Strategies

### RSpec Configuration
```ruby
# spec/rails_helper.rb
RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  
  # Database cleaner
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end
  
  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
```

### Model Testing
```ruby
# spec/models/user_spec.rb
RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_presence_of(:password) }
  end
  
  describe 'associations' do
    it { should have_many(:orders) }
    it { should have_many(:reviews) }
  end
  
  describe 'scopes' do
    let!(:active_user) { create(:user, active: true) }
    let!(:inactive_user) { create(:user, active: false) }
    
    it 'returns only active users' do
      expect(User.active).to include(active_user)
      expect(User.active).not_to include(inactive_user)
    end
  end
  
  describe 'methods' do
    let(:user) { create(:user) }
    
    it 'returns full name' do
      expect(user.full_name).to eq("#{user.first_name} #{user.last_name}")
    end
  end
end
```

### Controller Testing
```ruby
# spec/controllers/users_controller_spec.rb
RSpec.describe UsersController, type: :controller do
  let(:user) { create(:user) }
  
  describe 'GET #show' do
    context 'when user is authenticated' do
      before { sign_in user }
      
      it 'returns user data' do
        get :show, params: { id: user.id }
        expect(response).to have_http_status(:success)
        expect(assigns(:user)).to eq(user)
      end
    end
    
    context 'when user is not authenticated' do
      it 'redirects to login' do
        get :show, params: { id: user.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
```

### Integration Testing
```ruby
# spec/requests/api/v1/users_spec.rb
RSpec.describe 'API::V1::Users', type: :request do
  let(:user) { create(:user) }
  let(:headers) { { 'Authorization' => "Bearer #{user.auth_token}" } }
  
  describe 'GET /api/v1/users' do
    it 'returns users list' do
      get '/api/v1/users', headers: headers
      
      expect(response).to have_http_status(:success)
      expect(json_response['data']).to be_an(Array)
    end
  end
  
  describe 'POST /api/v1/users' do
    let(:valid_params) do
      {
        user: {
          email: 'test@example.com',
          password: 'password123',
          first_name: 'John',
          last_name: 'Doe'
        }
      }
    end
    
    it 'creates a new user' do
      expect {
        post '/api/v1/users', params: valid_params, headers: headers
      }.to change(User, :count).by(1)
      
      expect(response).to have_http_status(:created)
    end
  end
end
```

## Rails Deployment & DevOps

### Docker Configuration
```dockerfile
# Dockerfile
FROM ruby:3.2.0

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
```

```yaml
# docker-compose.yml
version: '3.8'
services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgres://postgres:password@db:5432/myapp_development
    depends_on:
      - db
      - redis
  
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: myapp_development
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
  
  redis:
    image: redis:7-alpine
  
  sidekiq:
    build: .
    command: bundle exec sidekiq
    depends_on:
      - db
      - redis

volumes:
  postgres_data:
```

### Production Configuration
```ruby
# config/environments/production.rb
Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  
  # Logging
  config.log_level = :info
  config.log_tags = [:request_id]
  
  # Caching
  config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] }
  
  # Assets
  config.assets.compile = false
  config.assets.digest = true
  
  # Security
  config.force_ssl = true
  
  # Performance
  config.active_record.dump_schema_after_migration = false
end
```

### Monitoring & Logging
```ruby
# config/initializers/lograge.rb
Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Json.new
  
  config.lograge.custom_options = lambda do |event|
    {
      time: event.time,
      host: event.payload[:host],
      remote_ip: event.payload[:remote_ip],
      user_id: event.payload[:user_id]
    }
  end
end

# Custom logging
class ApplicationController < ActionController::Base
  before_action :log_request
  
  private
  
  def log_request
    Rails.logger.info "Request: #{request.method} #{request.path} - User: #{current_user&.id}"
  end
end
```

## Common Interview Questions

### 1. Explain Rails Request Lifecycle
**Answer Framework:**
1. **Router**: Matches URL to controller action
2. **Controller**: Handles request, calls model
3. **Model**: Business logic, database interaction
4. **View**: Renders response
5. **Response**: Returns to client

**Code Example:**
```ruby
# Route
get '/users/:id', to: 'users#show'

# Controller
class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
  end
end

# View
# app/views/users/show.html.erb
<h1><%= @user.name %></h1>
```

### 2. How do you handle N+1 queries?
**Problem:**
```ruby
users = User.all
users.each { |user| puts user.orders.count }  # N+1 queries
```

**Solutions:**
```ruby
# 1. includes (LEFT OUTER JOIN)
users = User.includes(:orders)

# 2. preload (separate queries)
users = User.preload(:orders)

# 3. eager_load (LEFT OUTER JOIN)
users = User.eager_load(:orders)

# 4. counter_cache
class Order < ApplicationRecord
  belongs_to :user, counter_cache: true
end
```

### 3. Explain Rails Caching Strategies
**Types:**
1. **Page Caching**: Entire page
2. **Action Caching**: Controller action
3. **Fragment Caching**: View fragments
4. **Low-level Caching**: Custom caching

**Example:**
```ruby
# Fragment caching
<% cache("user_#{@user.id}_#{@user.updated_at}") do %>
  <div class="user">
    <h3><%= @user.name %></h3>
  </div>
<% end %>

# Low-level caching
def expensive_method
  Rails.cache.fetch("user_#{id}_expensive", expires_in: 1.hour) do
    # Expensive calculation
  end
end
```

### 4. How do you implement background jobs?
**Sidekiq Example:**
```ruby
# Job class
class EmailJob < ApplicationJob
  queue_as :default
  
  def perform(user_id, message)
    user = User.find(user_id)
    UserMailer.notification(user, message).deliver_now
  end
end

# Usage
EmailJob.perform_later(user.id, "Welcome!")

# Configuration
# config/initializers/sidekiq.rb
Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] }
end
```

### 5. Rails Security Best Practices
**Key Areas:**
1. **CSRF Protection**: `protect_from_forgery`
2. **SQL Injection**: Parameterized queries
3. **XSS Protection**: HTML escaping
4. **Authentication**: Strong passwords, sessions
5. **Authorization**: Role-based access

**Examples:**
```ruby
# CSRF Protection
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
end

# SQL Injection Prevention
User.where("name = ?", params[:name])  # Good
User.where("name = '#{params[:name]}'")  # Bad

# XSS Protection
<%= @user.bio %>  # Automatically escaped
```

### 6. How do you optimize Rails performance?
**Strategies:**
1. **Database**: Indexes, query optimization
2. **Caching**: Fragment, low-level caching
3. **Background Jobs**: Move heavy operations
4. **Asset Pipeline**: Minification, compression
5. **Connection Pooling**: Database connections

**Example:**
```ruby
# Database optimization
add_index :users, :email
User.includes(:orders).where(active: true)

# Caching
Rails.cache.fetch("expensive_calculation", expires_in: 1.hour) do
  # Expensive operation
end
```

### 7. Explain Rails Middleware
**Purpose**: Process requests/responses between client and application

**Example:**
```ruby
class CustomMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    # Before processing
    start_time = Time.current
    
    status, headers, response = @app.call(env)
    
    # After processing
    duration = Time.current - start_time
    Rails.logger.info "Request took #{duration}ms"
    
    [status, headers, response]
  end
end
```

### 8. How do you handle errors in Rails?
**Strategies:**
1. **Exception Handling**: `rescue_from`
2. **Custom Error Pages**: 404, 500 pages
3. **Logging**: Error tracking
4. **Monitoring**: External services

**Example:**
```ruby
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from StandardError, with: :internal_error
  
  private
  
  def not_found
    render json: { error: 'Not found' }, status: :not_found
  end
  
  def internal_error(exception)
    Rails.logger.error exception.message
    render json: { error: 'Internal error' }, status: :internal_server_error
  end
end
```

## Best Practices Summary

### Code Organization
1. **Fat Models, Skinny Controllers**: Business logic in models
2. **Service Objects**: Complex operations
3. **Concerns**: Shared functionality
4. **Policies**: Authorization logic

### Performance
1. **Database**: Proper indexing, query optimization
2. **Caching**: Strategic caching at multiple levels
3. **Background Jobs**: Heavy operations
4. **Monitoring**: Performance tracking

### Security
1. **Input Validation**: Sanitize user input
2. **Authentication**: Secure user management
3. **Authorization**: Role-based access control
4. **HTTPS**: Encrypted communication

### Testing
1. **Test Coverage**: Comprehensive test suite
2. **TDD**: Test-driven development
3. **Integration Tests**: End-to-end testing
4. **Performance Tests**: Load testing

Remember: Rails is a powerful framework, but understanding its internals and best practices is crucial for building scalable, maintainable applications. Focus on practical experience and real-world problem-solving.



