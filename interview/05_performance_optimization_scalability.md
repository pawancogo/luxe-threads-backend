# Performance Optimization & Scalability Guide

## Table of Contents
1. [Performance Fundamentals](#performance-fundamentals)
2. [Database Performance](#database-performance)
3. [Application Performance](#application-performance)
4. [Caching Strategies](#caching-strategies)
5. [Background Processing](#background-processing)
6. [Infrastructure Scaling](#infrastructure-scaling)
7. [Monitoring & Profiling](#monitoring--profiling)
8. [Common Performance Issues](#common-performance-issues)
9. [Interview Questions](#interview-questions)

## Performance Fundamentals

### Key Performance Metrics

#### Response Time
- **Target**: < 200ms for API responses
- **Critical**: < 100ms for database queries
- **Acceptable**: < 500ms for complex operations

#### Throughput
- **Requests per Second (RPS)**: Number of requests handled
- **Transactions per Second (TPS)**: Database operations
- **Concurrent Users**: Simultaneous active users

#### Resource Utilization
- **CPU Usage**: Should stay below 80%
- **Memory Usage**: Monitor for memory leaks
- **Disk I/O**: Database and file operations
- **Network I/O**: API calls and data transfer

### Performance Optimization Principles

1. **Measure First**: Profile before optimizing
2. **Identify Bottlenecks**: Find the slowest components
3. **Optimize Incrementally**: Make small, measurable changes
4. **Test Changes**: Verify improvements
5. **Monitor Continuously**: Track performance over time

## Database Performance

### Query Optimization

#### N+1 Query Problem
**Problem:**
```ruby
# Bad: N+1 queries
users = User.all
users.each { |user| puts user.orders.count }  # N+1 queries
```

**Solutions:**
```ruby
# Solution 1: includes (LEFT OUTER JOIN)
users = User.includes(:orders)
users.each { |user| puts user.orders.count }  # 2 queries total

# Solution 2: preload (separate queries)
users = User.preload(:orders)
users.each { |user| puts user.orders.count }  # 2 queries total

# Solution 3: eager_load (LEFT OUTER JOIN)
users = User.eager_load(:orders)
users.each { |user| puts user.orders.count }  # 1 query with JOIN

# Solution 4: counter_cache
class Order < ApplicationRecord
  belongs_to :user, counter_cache: true
end

# Migration
class AddOrdersCountToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :orders_count, :integer, default: 0
    User.reset_counters(User.ids, :orders)
  end
end
```

#### Query Analysis
```ruby
# Enable query logging
ActiveRecord::Base.logger = Logger.new(STDOUT)

# Analyze slow queries
# config/application.rb
config.active_record.logger = Logger.new(Rails.root.join('log', 'slow_queries.log'))

# Custom slow query logging
class ApplicationRecord < ActiveRecord::Base
  def self.log_slow_queries
    callback = lambda do |name, start, finish, id, payload|
      duration = finish - start
      if duration > 0.1  # Log queries slower than 100ms
        Rails.logger.warn "SLOW QUERY (#{duration.round(2)}s): #{payload[:sql]}"
      end
    end
    
    ActiveSupport::Notifications.subscribe('sql.active_record', callback)
  end
end
```

#### Database Indexing
```ruby
# Add indexes for frequently queried columns
class AddIndexesToUsers < ActiveRecord::Migration[7.0]
  def change
    # Single column indexes
    add_index :users, :email, unique: true
    add_index :users, :created_at
    add_index :users, :active
    
    # Composite indexes
    add_index :users, [:first_name, :last_name]
    add_index :orders, [:user_id, :created_at]
    add_index :orders, [:status, :created_at]
    
    # Partial indexes
    add_index :users, :email, where: "active = true"
    add_index :orders, :status, where: "status IN ('pending', 'processing')"
    
    # Covering indexes (PostgreSQL)
    add_index :users, :email, include: [:first_name, :last_name]
  end
end
```

#### Query Optimization Techniques
```ruby
# Use appropriate data types
class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email, limit: 255  # Limit string length
      t.integer :age  # Use integer instead of string for numbers
      t.decimal :balance, precision: 10, scale: 2  # Use decimal for money
      t.timestamps
    end
  end
end

# Optimize WHERE clauses
# Good: Use indexes
User.where(email: 'john@example.com')
User.where(created_at: 1.week.ago..Time.current)

# Bad: Functions in WHERE clauses
User.where("LOWER(email) = ?", 'john@example.com')  # Can't use index

# Good: Use database functions efficiently
User.where("created_at > ?", 1.week.ago)

# Limit result sets
User.limit(100)
User.where(active: true).limit(100)

# Use EXISTS instead of IN for subqueries
# Good
User.where("EXISTS (SELECT 1 FROM orders WHERE orders.user_id = users.id)")

# Bad
User.where("id IN (SELECT user_id FROM orders)")
```

### Database Scaling

#### Read Replicas
```ruby
# config/database.yml
production:
  primary:
    adapter: postgresql
    database: myapp_production
    host: primary-db.example.com
    username: <%= ENV['DB_USERNAME'] %>
    password: <%= ENV['DB_PASSWORD'] %>
  
  primary_replica:
    adapter: postgresql
    database: myapp_production
    host: replica-db.example.com
    username: <%= ENV['DB_USERNAME'] %>
    password: <%= ENV['DB_PASSWORD'] %>
    replica: true

# app/models/application_record.rb
class ApplicationRecord < ActiveRecord::Base
  connects_to database: { writing: :primary, reading: :primary_replica }
end

# app/models/user.rb
class User < ApplicationRecord
  # Use replica for read operations
  def self.find_with_replica(id)
    connected_to(role: :reading) do
      find(id)
    end
  end
  
  # Use primary for write operations
  def save_with_primary
    connected_to(role: :writing) do
      save
    end
  end
end
```

#### Database Sharding
```ruby
# Sharding by user ID
class User < ApplicationRecord
  def self.shard_for_user_id(user_id)
    shard_number = user_id % 4  # 4 shards
    "shard_#{shard_number}"
  end
  
  def self.find_on_shard(user_id)
    shard = shard_for_user_id(user_id)
    connected_to(database: shard.to_sym) do
      find(user_id)
    end
  end
end

# Sharding configuration
# config/database.yml
production:
  shard_0:
    adapter: postgresql
    database: myapp_shard_0
    host: shard-0.example.com
  
  shard_1:
    adapter: postgresql
    database: myapp_shard_1
    host: shard-1.example.com
  
  shard_2:
    adapter: postgresql
    database: myapp_shard_2
    host: shard-2.example.com
  
  shard_3:
    adapter: postgresql
    database: myapp_shard_3
    host: shard-3.example.com
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
  idle_timeout: 300

# Custom connection pool configuration
# config/initializers/database.rb
Rails.application.configure do
  config.after_initialize do
    ActiveRecord::Base.connection_pool.disconnect!
    
    ActiveRecord::Base.establish_connection(
      Rails.application.config.database_configuration[Rails.env].merge(
        pool: 20,
        timeout: 5000,
        checkout_timeout: 5
      )
    )
  end
end
```

## Application Performance

### Memory Optimization

#### Object Allocation Tracking
```ruby
# Gemfile
gem 'memory_profiler'
gem 'stackprof'

# Memory profiling
require 'memory_profiler'

report = MemoryProfiler.report do
  User.includes(:orders).limit(1000).each do |user|
    user.orders.sum(:total_amount)
  end
end

report.pretty_print

# Stack profiling
require 'stackprof'

StackProf.run(mode: :cpu, out: 'tmp/stackprof.dump') do
  # Your code here
end

# Analyze results
# stackprof tmp/stackprof.dump
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

# Use pluck for specific columns
user_ids = User.where(active: true).pluck(:id)
user_emails = User.where(active: true).pluck(:email)

# Use select for specific columns
users = User.select(:id, :email, :first_name).where(active: true)
```

#### Memory Management
```ruby
# Clear unused objects
def process_large_dataset
  users = User.all
  
  users.each do |user|
    process_user(user)
    user = nil  # Help GC
  end
  
  users = nil  # Clear reference
  GC.start     # Force garbage collection
end

# Use streaming for large files
def process_csv_file(file_path)
  CSV.foreach(file_path, headers: true) do |row|
    process_row(row)
  end
end

# Use database streaming
def export_users_to_csv
  require 'csv'
  
  CSV.open('users.csv', 'w') do |csv|
    csv << ['id', 'email', 'first_name', 'last_name']
    
    User.find_each do |user|
      csv << [user.id, user.email, user.first_name, user.last_name]
    end
  end
end
```

### CPU Optimization

#### Algorithm Optimization
```ruby
# Bad: O(n²) algorithm
def find_duplicate_emails
  users = User.all
  duplicates = []
  
  users.each_with_index do |user1, i|
    users.each_with_index do |user2, j|
      next if i >= j
      if user1.email == user2.email
        duplicates << [user1, user2]
      end
    end
  end
  
  duplicates
end

# Good: O(n) algorithm
def find_duplicate_emails
  email_groups = User.group(:email).having('COUNT(*) > 1')
  email_groups.includes(:users)
end

# Bad: Multiple database queries
def calculate_user_stats
  total_users = User.count
  active_users = User.where(active: true).count
  premium_users = User.where(premium: true).count
  
  { total: total_users, active: active_users, premium: premium_users }
end

# Good: Single query with aggregation
def calculate_user_stats
  stats = User.group('1').select(
    'COUNT(*) as total',
    'COUNT(CASE WHEN active = true THEN 1 END) as active',
    'COUNT(CASE WHEN premium = true THEN 1 END) as premium'
  ).first
  
  { total: stats.total, active: stats.active, premium: stats.premium }
end
```

#### Caching Expensive Calculations
```ruby
class User < ApplicationRecord
  def expensive_calculation
    Rails.cache.fetch("user_#{id}_expensive_calculation", expires_in: 1.hour) do
      # Expensive operation
      calculate_user_metrics
    end
  end
  
  def calculate_user_metrics
    # Complex calculation
    orders = self.orders.includes(:order_items)
    total_spent = orders.sum(&:total_amount)
    average_order_value = total_spent / orders.count.to_f
    favorite_category = orders.joins(:products).group('products.category_id').count.max_by(&:last)
    
    {
      total_spent: total_spent,
      average_order_value: average_order_value,
      favorite_category: favorite_category
    }
  end
end
```

## Caching Strategies

### Application-Level Caching

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
  after_destroy :clear_cache
  
  private
  
  def clear_cache
    Rails.cache.delete("user_#{id}_expensive_calculation")
    Rails.cache.delete("top_users")
    Rails.cache.delete_matched("users_*")
  end
end
```

### Redis Caching

#### Redis Configuration
```ruby
# config/initializers/redis.rb
Redis.current = Redis.new(
  host: ENV['REDIS_HOST'] || 'localhost',
  port: ENV['REDIS_PORT'] || 6379,
  db: ENV['REDIS_DB'] || 0,
  timeout: 5,
  reconnect_attempts: 3
)

# config/application.rb
config.cache_store = :redis_cache_store, {
  url: ENV['REDIS_URL'],
  namespace: 'myapp',
  expires_in: 1.hour
}
```

#### Redis Usage Patterns
```ruby
class User < ApplicationRecord
  def self.find_cached(id)
    Rails.cache.fetch("user:#{id}", expires_in: 1.hour) do
      find(id)
    end
  end
  
  def self.search_cached(query)
    cache_key = "user_search:#{Digest::MD5.hexdigest(query)}"
    Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
      where("first_name ILIKE ? OR last_name ILIKE ?", "%#{query}%", "%#{query}%")
    end
  end
  
  def increment_view_count
    Redis.current.incr("user:#{id}:views")
  end
  
  def view_count
    Redis.current.get("user:#{id}:views").to_i
  end
end
```

### CDN Integration

#### Asset CDN
```ruby
# config/environments/production.rb
Rails.application.configure do
  config.asset_host = 'https://cdn.example.com'
  config.assets.compile = false
  config.assets.digest = true
  config.assets.cache_store = :file_store, Rails.root.join('tmp', 'cache', 'assets')
end
```

#### API Response CDN
```ruby
class Api::V1::UsersController < ApplicationController
  def index
    @users = User.all
    
    if stale?(@users, public: true, last_modified: @users.maximum(:updated_at))
      render json: @users
    end
  end
end
```

## Background Processing

### Sidekiq Configuration

#### Basic Setup
```ruby
# Gemfile
gem 'sidekiq'
gem 'sidekiq-cron'

# config/initializers/sidekiq.rb
Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] }
  config.concurrency = ENV.fetch('SIDEKIQ_CONCURRENCY', 5).to_i
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
```

#### Advanced Job Patterns
```ruby
# Job with retry logic
class ProcessOrderJob < ApplicationJob
  queue_as :high_priority
  retry_on StandardError, wait: :exponentially_longer, attempts: 3
  
  def perform(order_id)
    order = Order.find(order_id)
    process_order(order)
  end
  
  private
  
  def process_order(order)
    # Process order logic
    order.update!(status: 'processed')
  end
end

# Job with callbacks
class UserRegistrationJob < ApplicationJob
  queue_as :default
  
  before_perform :log_start
  after_perform :log_completion
  around_perform :with_retry
  
  def perform(user_id)
    user = User.find(user_id)
    send_welcome_email(user)
    create_user_profile(user)
  end
  
  private
  
  def log_start
    Rails.logger.info "Starting user registration for user #{arguments[0]}"
  end
  
  def log_completion
    Rails.logger.info "Completed user registration for user #{arguments[0]}"
  end
  
  def with_retry
    yield
  rescue StandardError => e
    Rails.logger.error "User registration failed: #{e.message}"
    raise
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

### Job Monitoring
```ruby
# config/routes.rb
require 'sidekiq/web'
mount Sidekiq::Web => '/sidekiq'

# Custom monitoring
class ApplicationJob < ActiveJob::Base
  rescue_from StandardError do |exception|
    Rails.logger.error "Job failed: #{exception.message}"
    ErrorTracker.notify(exception)
  end
end
```

## Infrastructure Scaling

### Horizontal Scaling

#### Load Balancing
```ruby
# Nginx configuration
upstream rails_app {
    server app1.example.com:3000;
    server app2.example.com:3000;
    server app3.example.com:3000;
}

server {
    listen 80;
    server_name example.com;
    
    location / {
        proxy_pass http://rails_app;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

#### Application Server Scaling
```ruby
# config/puma.rb
workers ENV.fetch("WEB_CONCURRENCY") { 2 }
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "development" }

on_worker_boot do
  ActiveRecord::Base.establish_connection
end
```

### Vertical Scaling

#### Memory Optimization
```ruby
# config/application.rb
Rails.application.configure do
  # Optimize memory usage
  config.active_record.dump_schema_after_migration = false
  config.active_record.cache_versioning = false
  
  # Reduce memory footprint
  config.force_ssl = true
  config.ssl_options = { redirect: { exclude: ->(request) { request.path =~ /health/ } } }
end
```

#### CPU Optimization
```ruby
# Use connection pooling
# config/database.yml
production:
  adapter: postgresql
  database: myapp_production
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000
  checkout_timeout: 5
  reaping_frequency: 10
```

## Monitoring & Profiling

### Application Monitoring

#### Performance Monitoring
```ruby
# Gemfile
gem 'newrelic_rpm'
gem 'rack-mini-profiler'

# config/initializers/newrelic.rb
NewRelic::Agent.manual_start

# Custom performance monitoring
class ApplicationController < ActionController::Base
  around_action :log_performance
  
  private
  
  def log_performance
    start_time = Time.current
    yield
    duration = Time.current - start_time
    
    if duration > 0.5  # Log slow requests
      Rails.logger.warn "SLOW REQUEST: #{request.path} took #{duration.round(2)}s"
    end
  end
end
```

#### Error Tracking
```ruby
# Gemfile
gem 'sentry-ruby'
gem 'sentry-rails'

# config/initializers/sentry.rb
Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.traces_sample_rate = 0.1
end

# Custom error tracking
class ApplicationController < ActionController::Base
  rescue_from StandardError do |exception|
    Sentry.capture_exception(exception)
    raise
  end
end
```

### Database Monitoring

#### Query Performance
```ruby
# config/application.rb
Rails.application.configure do
  config.active_record.logger = Logger.new(Rails.root.join('log', 'slow_queries.log'))
end

# Custom slow query logging
class ApplicationRecord < ActiveRecord::Base
  def self.log_slow_queries
    callback = lambda do |name, start, finish, id, payload|
      duration = finish - start
      if duration > 0.1  # Log queries slower than 100ms
        Rails.logger.warn "SLOW QUERY (#{duration.round(2)}s): #{payload[:sql]}"
      end
    end
    
    ActiveSupport::Notifications.subscribe('sql.active_record', callback)
  end
end
```

#### Database Health Checks
```ruby
# app/controllers/health_controller.rb
class HealthController < ApplicationController
  def check
    checks = {
      database: check_database,
      redis: check_redis,
      sidekiq: check_sidekiq
    }
    
    if checks.values.all?
      render json: { status: 'healthy', checks: checks }
    else
      render json: { status: 'unhealthy', checks: checks }, status: :service_unavailable
    end
  end
  
  private
  
  def check_database
    ActiveRecord::Base.connection.execute('SELECT 1')
    true
  rescue StandardError
    false
  end
  
  def check_redis
    Redis.current.ping == 'PONG'
  rescue StandardError
    false
  end
  
  def check_sidekiq
    Sidekiq::Stats.new.processed > 0
  rescue StandardError
    false
  end
end
```

## Common Performance Issues

### Memory Leaks

#### Object Retention
```ruby
# Bad: Retaining large objects
class UserController < ApplicationController
  def index
    @users = User.all  # Loads all users into memory
    # @users is retained until request completes
  end
end

# Good: Process in batches
class UserController < ApplicationController
  def index
    @users = User.limit(100)  # Limit memory usage
  end
end
```

#### Circular References
```ruby
# Bad: Circular references
class User < ApplicationRecord
  has_many :orders
end

class Order < ApplicationRecord
  belongs_to :user
end

# Good: Use weak references or clear references
class User < ApplicationRecord
  has_many :orders, dependent: :destroy
end
```

### Database Issues

#### Missing Indexes
```ruby
# Bad: No index on frequently queried column
User.where(email: 'john@example.com')  # Full table scan

# Good: Add index
add_index :users, :email
```

#### Inefficient Queries
```ruby
# Bad: Multiple queries
users = User.all
users.each { |user| puts user.orders.count }  # N+1 queries

# Good: Use includes
users = User.includes(:orders)
users.each { |user| puts user.orders.count }  # 2 queries total
```

### Caching Issues

#### Cache Invalidation
```ruby
# Bad: Stale cache
class User < ApplicationRecord
  def expensive_calculation
    Rails.cache.fetch("user_#{id}_calculation") do
      # Expensive operation
    end
  end
end

# Good: Proper cache invalidation
class User < ApplicationRecord
  after_update :clear_cache
  
  def expensive_calculation
    Rails.cache.fetch("user_#{id}_calculation", expires_in: 1.hour) do
      # Expensive operation
    end
  end
  
  private
  
  def clear_cache
    Rails.cache.delete("user_#{id}_calculation")
  end
end
```

## Interview Questions

### 1. How do you identify performance bottlenecks?
**Answer:**
1. **Profiling Tools**: Use tools like New Relic, StackProf
2. **Database Analysis**: Check slow query logs
3. **Memory Profiling**: Monitor memory usage and leaks
4. **Load Testing**: Simulate high traffic scenarios
5. **Monitoring**: Set up alerts for performance metrics

**Example:**
```ruby
# Enable query logging
ActiveRecord::Base.logger = Logger.new(STDOUT)

# Profile memory usage
require 'memory_profiler'
report = MemoryProfiler.report do
  # Your code here
end
report.pretty_print
```

### 2. Explain the N+1 query problem and solutions
**Problem:**
```ruby
# N+1 queries
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

### 3. How do you implement caching in Rails?
**Answer:**
1. **Fragment Caching**: Cache view fragments
2. **Low-level Caching**: Cache expensive calculations
3. **HTTP Caching**: Use ETags and Last-Modified headers
4. **Redis Caching**: External cache store

**Example:**
```ruby
# Fragment caching
<% cache("user_#{@user.id}_#{@user.updated_at}") do %>
  <div class="user">
    <h3><%= @user.name %></h3>
  </div>
<% end %>

# Low-level caching
def expensive_calculation
  Rails.cache.fetch("user_#{id}_calculation", expires_in: 1.hour) do
    # Expensive operation
  end
end
```

### 4. How do you scale a Rails application?
**Answer:**
1. **Horizontal Scaling**: Add more application servers
2. **Database Scaling**: Read replicas, sharding
3. **Caching**: Multiple cache layers
4. **Background Jobs**: Move heavy operations
5. **CDN**: Static content delivery

**Example:**
```ruby
# Read replicas
class User < ApplicationRecord
  def self.find_with_replica(id)
    connected_to(role: :reading) do
      find(id)
    end
  end
end

# Background jobs
class ProcessOrderJob < ApplicationJob
  def perform(order_id)
    # Heavy processing
  end
end
```

### 5. How do you monitor application performance?
**Answer:**
1. **APM Tools**: New Relic, DataDog, AppDynamics
2. **Logging**: Structured logging with correlation IDs
3. **Metrics**: Custom business metrics
4. **Alerts**: Set up performance thresholds
5. **Health Checks**: Monitor dependencies

**Example:**
```ruby
# Custom performance monitoring
class ApplicationController < ActionController::Base
  around_action :log_performance
  
  private
  
  def log_performance
    start_time = Time.current
    yield
    duration = Time.current - start_time
    
    if duration > 0.5
      Rails.logger.warn "SLOW REQUEST: #{request.path} took #{duration.round(2)}s"
    end
  end
end
```

### 6. How do you optimize database performance?
**Answer:**
1. **Indexing**: Add indexes for frequently queried columns
2. **Query Optimization**: Use includes, preload, eager_load
3. **Connection Pooling**: Optimize database connections
4. **Read Replicas**: Distribute read load
5. **Query Analysis**: Monitor slow queries

**Example:**
```ruby
# Add indexes
add_index :users, :email
add_index :orders, [:user_id, :created_at]

# Optimize queries
users = User.includes(:orders).where(active: true)
```

### 7. How do you handle memory leaks in Rails?
**Answer:**
1. **Object Retention**: Avoid retaining large objects
2. **Circular References**: Break circular dependencies
3. **Memory Profiling**: Use tools to identify leaks
4. **Garbage Collection**: Force GC when appropriate
5. **Batch Processing**: Process large datasets in batches

**Example:**
```ruby
# Process in batches
User.find_each(batch_size: 1000) do |user|
  process_user(user)
end

# Clear references
def process_large_dataset
  users = User.all
  users.each do |user|
    process_user(user)
    user = nil  # Help GC
  end
  users = nil  # Clear reference
  GC.start     # Force garbage collection
end
```

### 8. How do you implement background job processing?
**Answer:**
1. **Sidekiq**: Redis-based job processing
2. **Job Queues**: Different queues for different priorities
3. **Retry Logic**: Handle job failures gracefully
4. **Monitoring**: Track job performance
5. **Scheduling**: Cron-like job scheduling

**Example:**
```ruby
# Job class
class EmailNotificationJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: :exponentially_longer, attempts: 3
  
  def perform(user_id, message)
    user = User.find(user_id)
    UserMailer.notification(user, message).deliver_now
  end
end

# Usage
EmailNotificationJob.perform_later(user.id, "Welcome!")
```

### 9. How do you implement caching strategies?
**Answer:**
1. **Cache Levels**: Application, database, CDN
2. **Cache Invalidation**: Proper cache invalidation
3. **Cache Keys**: Meaningful cache keys
4. **Cache Expiration**: Set appropriate TTL
5. **Cache Warming**: Pre-populate cache

**Example:**
```ruby
# Multi-level caching
class User < ApplicationRecord
  def expensive_calculation
    Rails.cache.fetch("user_#{id}_calculation", expires_in: 1.hour) do
      # Expensive operation
    end
  end
  
  after_update :clear_cache
  
  private
  
  def clear_cache
    Rails.cache.delete("user_#{id}_calculation")
  end
end
```

### 10. How do you handle high traffic scenarios?
**Answer:**
1. **Load Balancing**: Distribute traffic across servers
2. **Caching**: Reduce database load
3. **Database Optimization**: Read replicas, connection pooling
4. **Background Jobs**: Move heavy operations
5. **CDN**: Serve static content from edge locations

**Example:**
```ruby
# Load balancing with Nginx
upstream rails_app {
    server app1.example.com:3000;
    server app2.example.com:3000;
    server app3.example.com:3000;
}

# Caching
def index
  @users = Rails.cache.fetch("users_index", expires_in: 30.minutes) do
    User.includes(:orders).limit(100)
  end
end
```

## Best Practices Summary

### Performance Optimization
1. **Measure First**: Profile before optimizing
2. **Identify Bottlenecks**: Find the slowest components
3. **Optimize Incrementally**: Make small, measurable changes
4. **Test Changes**: Verify improvements
5. **Monitor Continuously**: Track performance over time

### Database Performance
1. **Proper Indexing**: Add indexes for frequently queried columns
2. **Query Optimization**: Use includes, preload, eager_load
3. **Connection Pooling**: Optimize database connections
4. **Read Replicas**: Distribute read load
5. **Query Analysis**: Monitor slow queries

### Caching Strategies
1. **Multiple Levels**: Application, database, CDN
2. **Proper Invalidation**: Clear cache when data changes
3. **Meaningful Keys**: Use descriptive cache keys
4. **Appropriate TTL**: Set reasonable expiration times
5. **Cache Warming**: Pre-populate frequently accessed data

### Monitoring & Profiling
1. **APM Tools**: Use application performance monitoring
2. **Logging**: Structured logging with correlation IDs
3. **Metrics**: Custom business metrics
4. **Alerts**: Set up performance thresholds
5. **Health Checks**: Monitor dependencies

Remember: Performance optimization is an iterative process. Start with the most impactful changes and measure the results before making additional optimizations. Focus on the user experience and business requirements when making performance decisions.



