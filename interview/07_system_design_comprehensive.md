# Comprehensive System Design Guide

## Table of Contents
1. [Fundamental Intuitions](#fundamental-intuitions)
2. [High-Level System Design](#high-level-system-design)
3. [Low-Level System Design](#low-level-system-design)
4. [Design Patterns & Architectures](#design-patterns--architectures)
5. [Scalability Strategies](#scalability-strategies)
6. [Performance Optimization](#performance-optimization)
7. [Reliability & Fault Tolerance](#reliability--fault-tolerance)
8. [Security Considerations](#security-considerations)
9. [Common System Design Problems](#common-system-design-problems)
10. [Interview Framework](#interview-framework)

## Fundamental Intuitions

### Before You Start Designing

#### 1. **Understand the Problem First**
```
❌ Don't jump to solutions
✅ Ask clarifying questions
✅ Understand the real requirements
✅ Identify constraints and assumptions
```

**Key Questions to Ask:**
- What is the core functionality?
- Who are the users and how many?
- What are the performance requirements?
- What are the constraints (budget, time, team size)?
- What are the non-functional requirements?

#### 2. **Think in Terms of Trade-offs**
Every design decision involves trade-offs:
- **Consistency vs Availability** (CAP Theorem)
- **Performance vs Complexity**
- **Cost vs Scalability**
- **Development Speed vs Maintainability**

#### 3. **Start Simple, Then Scale**
```
MVP → Scale → Optimize → Refactor
```
- Build a working system first
- Identify bottlenecks
- Scale incrementally
- Optimize based on real usage patterns

#### 4. **Design for Failure**
- Systems will fail
- Plan for partial failures
- Design graceful degradation
- Implement monitoring and alerting

#### 5. **Consider the Full Stack**
- Frontend → Backend → Database
- Network → Load Balancer → Application Server
- Caching → CDN → Storage
- Monitoring → Logging → Analytics

### Core Design Principles

#### 1. **Separation of Concerns**
```
Presentation Layer → Business Logic → Data Access
```
- Each layer has a single responsibility
- Changes in one layer don't affect others
- Easier to test and maintain

#### 2. **Loose Coupling, High Cohesion**
- Components should be independent
- Related functionality should be grouped together
- Use interfaces and abstractions

#### 3. **Fail Fast and Fail Safe**
- Detect errors early
- Provide meaningful error messages
- Implement circuit breakers
- Have fallback mechanisms

#### 4. **Design for Observability**
- Logging at appropriate levels
- Metrics for key business and technical indicators
- Distributed tracing
- Health checks and monitoring

## High-Level System Design

### System Architecture Patterns

#### 1. **Monolithic Architecture**
```
┌─────────────────────────────────────┐
│           Monolithic App            │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐   │
│  │ UI  │ │ API │ │ BL  │ │ DB  │   │
│  └─────┘ └─────┘ └─────┘ └─────┘   │
└─────────────────────────────────────┘
```

**Characteristics:**
- Single deployable unit
- Shared database
- Simple to develop and deploy
- Hard to scale individual components

**When to Use:**
- Small to medium applications
- Simple business logic
- Small development team
- Rapid prototyping

**Example:**
```ruby
# Rails monolithic application
class UsersController < ApplicationController
  def create
    @user = User.new(user_params)
    if @user.save
      UserMailer.welcome(@user).deliver_later
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end
end
```

#### 2. **Microservices Architecture**
```
┌─────────┐    ┌─────────┐    ┌─────────┐
│ User    │    │ Order   │    │ Payment │
│ Service │    │ Service │    │ Service │
└─────────┘    └─────────┘    └─────────┘
     │              │              │
┌─────────┐    ┌─────────┐    ┌─────────┐
│ User    │    │ Order   │    │ Payment │
│ DB      │    │ DB      │    │ DB      │
└─────────┘    └─────────┘    └─────────┘
```

**Characteristics:**
- Independent deployable services
- Each service has its own database
- Service-to-service communication
- Technology diversity

**When to Use:**
- Large, complex applications
- Multiple development teams
- Different scaling requirements
- Technology diversity needs

**Example:**
```ruby
# User Service
class UserService
  def create_user(user_data)
    user = User.create(user_data)
    # Publish event to other services
    EventBus.publish('user.created', user.id)
    user
  end
end

# Order Service
class OrderService
  def create_order(order_data, user_id)
    # Validate user exists via User Service
    user = UserServiceClient.get_user(user_id)
    order = Order.create(order_data.merge(user_id: user_id))
    order
  end
end
```

#### 3. **Event-Driven Architecture**
```
┌─────────┐    ┌─────────┐    ┌─────────┐
│ Service │    │ Event   │    │ Service │
│    A    │───▶│  Bus    │───▶│    B    │
└─────────┘    └─────────┘    └─────────┘
```

**Characteristics:**
- Loose coupling through events
- Asynchronous communication
- Event sourcing capabilities
- Eventual consistency

**Example:**
```ruby
# Event Publisher
class OrderService
  def create_order(order_data)
    order = Order.create(order_data)
    EventBus.publish('order.created', {
      order_id: order.id,
      user_id: order.user_id,
      total_amount: order.total_amount
    })
    order
  end
end

# Event Subscriber
class InventoryService
  def handle_order_created(event)
    order_id = event[:order_id]
    # Update inventory
    update_inventory_for_order(order_id)
  end
end
```

### High-Level Components

#### 1. **Load Balancer**
```
┌─────────┐    ┌─────────┐
│ Client  │───▶│  Load   │
│         │    │Balancer │
└─────────┘    └─────────┘
                    │
        ┌───────────┼───────────┐
        │           │           │
   ┌─────────┐ ┌─────────┐ ┌─────────┐
   │ Server  │ │ Server  │ │ Server  │
   │    1    │ │    2    │ │    3    │
   └─────────┘ └─────────┘ └─────────┘
```

**Types:**
- **Round Robin**: Distribute requests evenly
- **Weighted Round Robin**: Assign weights to servers
- **Least Connections**: Route to server with fewest connections
- **IP Hash**: Route based on client IP
- **Geographic**: Route based on user location

**Implementation:**
```nginx
# Nginx Load Balancer Configuration
upstream backend {
    server app1.example.com:3000 weight=3;
    server app2.example.com:3000 weight=2;
    server app3.example.com:3000 weight=1;
}

server {
    listen 80;
    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

#### 2. **API Gateway**
```
┌─────────┐    ┌─────────┐    ┌─────────┐
│ Client  │───▶│   API   │───▶│ Service │
│         │    │ Gateway │    │    A    │
└─────────┘    └─────────┘    └─────────┘
                      │
                      ▼
                ┌─────────┐
                │ Service │
                │    B    │
                └─────────┘
```

**Responsibilities:**
- Request routing
- Authentication and authorization
- Rate limiting
- Request/response transformation
- Monitoring and logging

**Example:**
```ruby
# API Gateway with Rails
class ApiGatewayController < ApplicationController
  before_action :authenticate_request
  before_action :rate_limit
  before_action :route_request
  
  private
  
  def route_request
    case request.path
    when /^\/users/
      forward_to_user_service
    when /^\/orders/
      forward_to_order_service
    else
      render json: { error: 'Not found' }, status: :not_found
    end
  end
  
  def forward_to_user_service
    response = UserServiceClient.request(request)
    render json: response.body, status: response.status
  end
end
```

#### 3. **Service Discovery**
```
┌─────────┐    ┌─────────┐
│ Service │───▶│Service  │
│    A    │    │Registry │
└─────────┘    └─────────┘
                      ▲
                      │
                ┌─────────┐
                │ Service │
                │    B    │
                └─────────┘
```

**Patterns:**
- **Client-side Discovery**: Client queries service registry
- **Server-side Discovery**: Load balancer queries service registry
- **Service Registry**: Central registry of available services

**Example:**
```ruby
# Service Registry
class ServiceRegistry
  def self.register_service(service_name, host, port)
    redis.hset("services:#{service_name}", "#{host}:#{port}", Time.current.to_i)
  end
  
  def self.discover_service(service_name)
    services = redis.hgetall("services:#{service_name}")
    # Return healthy services
    services.select { |k, v| Time.current.to_i - v.to_i < 30 }
  end
end
```

## Low-Level System Design

### Database Design Patterns

#### 1. **Database Sharding**
```
┌─────────┐    ┌─────────┐    ┌─────────┐
│ Shard 1 │    │ Shard 2 │    │ Shard 3 │
│User 1-3 │    │User 4-6 │    │User 7-9 │
└─────────┘    └─────────┘    └─────────┘
```

**Sharding Strategies:**
- **Range-based**: Split by ID ranges
- **Hash-based**: Use hash function on key
- **Directory-based**: Lookup table for shard mapping

**Implementation:**
```ruby
class User
  def self.shard_for_user_id(user_id)
    shard_number = user_id % 3  # 3 shards
    "shard_#{shard_number}"
  end
  
  def self.find_on_shard(user_id)
    shard = shard_for_user_id(user_id)
    connected_to(database: shard.to_sym) do
      find(user_id)
    end
  end
end
```

#### 2. **Read Replicas**
```
┌─────────┐    ┌─────────┐
│ Master  │───▶│ Replica │
│   DB    │    │   1     │
└─────────┘    └─────────┘
     │              │
     ▼              ▼
┌─────────┐    ┌─────────┐
│ Replica │    │ Replica │
│   2     │    │   3     │
└─────────┘    └─────────┘
```

**Implementation:**
```ruby
# Rails Database Configuration
production:
  primary:
    adapter: postgresql
    database: myapp_production
    host: primary-db.example.com
  
  primary_replica:
    adapter: postgresql
    database: myapp_production
    host: replica-db.example.com
    replica: true

# Usage
class User < ApplicationRecord
  def self.find_with_replica(id)
    connected_to(role: :reading) do
      find(id)
    end
  end
end
```

#### 3. **Caching Strategies**

**Cache-Aside Pattern:**
```ruby
class UserService
  def find_user(user_id)
    # Check cache first
    user = Rails.cache.read("user:#{user_id}")
    
    if user.nil?
      # Cache miss - fetch from database
      user = User.find(user_id)
      Rails.cache.write("user:#{user_id}", user, expires_in: 1.hour)
    end
    
    user
  end
end
```

**Write-Through Pattern:**
```ruby
class UserService
  def update_user(user_id, attributes)
    user = User.find(user_id)
    user.update!(attributes)
    
    # Update cache
    Rails.cache.write("user:#{user_id}", user, expires_in: 1.hour)
    
    user
  end
end
```

**Write-Behind Pattern:**
```ruby
class UserService
  def update_user(user_id, attributes)
    # Update cache immediately
    Rails.cache.write("user:#{user_id}", attributes, expires_in: 1.hour)
    
    # Queue database update
    DatabaseUpdateJob.perform_later(user_id, attributes)
  end
end
```

### Message Queue Patterns

#### 1. **Producer-Consumer Pattern**
```
┌─────────┐    ┌─────────┐    ┌─────────┐
│Producer │───▶│ Message │───▶│Consumer │
│         │    │ Queue   │    │         │
└─────────┘    └─────────┘    └─────────┘
```

**Implementation:**
```ruby
# Producer
class OrderService
  def create_order(order_data)
    order = Order.create(order_data)
    
    # Publish to queue
    MessageQueue.publish('order.created', {
      order_id: order.id,
      user_id: order.user_id,
      total_amount: order.total_amount
    })
    
    order
  end
end

# Consumer
class InventoryConsumer
  def process_order_created(message)
    order_id = message[:order_id]
    # Process inventory update
    update_inventory_for_order(order_id)
  end
end
```

#### 2. **Pub-Sub Pattern**
```
┌─────────┐    ┌─────────┐    ┌─────────┐
│Publisher│───▶│  Topic  │───▶│Subscriber│
│         │    │         │    │    A    │
└─────────┘    └─────────┘    └─────────┘
                      │
                      ▼
                ┌─────────┐
                │Subscriber│
                │    B    │
                └─────────┘
```

**Implementation:**
```ruby
# Publisher
class EventPublisher
  def self.publish_event(topic, event_data)
    Redis.publish(topic, event_data.to_json)
  end
end

# Subscriber
class EventSubscriber
  def self.subscribe_to_topic(topic, handler)
    Redis.subscribe(topic) do |on|
      on.message do |channel, message|
        event_data = JSON.parse(message)
        handler.call(event_data)
      end
    end
  end
end
```

### Data Consistency Patterns

#### 1. **ACID Transactions**
```ruby
class OrderService
  def create_order_with_payment(order_data, payment_data)
    ActiveRecord::Base.transaction do
      order = Order.create!(order_data)
      payment = Payment.create!(payment_data.merge(order_id: order.id))
      
      # If any step fails, entire transaction rolls back
      raise "Payment failed" unless payment.process
      
      order
    end
  end
end
```

#### 2. **Eventual Consistency**
```ruby
class UserService
  def update_user_profile(user_id, profile_data)
    # Update user profile
    user = User.find(user_id)
    user.update!(profile_data)
    
    # Publish event for eventual consistency
    EventBus.publish('user.profile.updated', {
      user_id: user_id,
      profile_data: profile_data
    })
  end
end

# Eventually consistent service
class SearchService
  def handle_profile_update(event)
    user_id = event[:user_id]
    profile_data = event[:profile_data]
    
    # Update search index
    SearchIndex.update_user_profile(user_id, profile_data)
  end
end
```

#### 3. **Saga Pattern**
```ruby
class OrderSaga
  def create_order(order_data)
    steps = [
      -> { create_order_record(order_data) },
      -> { reserve_inventory(order_data[:items]) },
      -> { process_payment(order_data[:payment]) },
      -> { send_confirmation_email(order_data[:user_id]) }
    ]
    
    compensations = []
    
    steps.each do |step|
      begin
        result = step.call
        compensations.unshift(create_compensation(step, result))
      rescue => e
        # Compensate for previous steps
        compensations.each(&:call)
        raise e
      end
    end
  end
end
```

## Design Patterns & Architectures

### 1. **Circuit Breaker Pattern**
```ruby
class CircuitBreaker
  def initialize(threshold: 5, timeout: 60)
    @threshold = threshold
    @timeout = timeout
    @failure_count = 0
    @last_failure_time = nil
    @state = :closed
  end
  
  def call(&block)
    case @state
    when :open
      if Time.current - @last_failure_time > @timeout
        @state = :half_open
      else
        raise "Circuit breaker is open"
      end
    when :half_open
      # Allow one request to test
    end
    
    begin
      result = block.call
      on_success
      result
    rescue => e
      on_failure
      raise e
    end
  end
  
  private
  
  def on_success
    @failure_count = 0
    @state = :closed
  end
  
  def on_failure
    @failure_count += 1
    @last_failure_time = Time.current
    
    if @failure_count >= @threshold
      @state = :open
    end
  end
end
```

### 2. **Bulkhead Pattern**
```ruby
class ResourcePool
  def initialize(pool_size: 10)
    @pool = Queue.new
    @pool_size = pool_size
    @mutex = Mutex.new
    
    initialize_pool
  end
  
  def with_resource(&block)
    resource = acquire_resource
    begin
      yield(resource)
    ensure
      release_resource(resource)
    end
  end
  
  private
  
  def acquire_resource
    @mutex.synchronize do
      if @pool.empty?
        create_new_resource
      else
        @pool.pop
      end
    end
  end
  
  def release_resource(resource)
    @mutex.synchronize do
      @pool.push(resource) if @pool.size < @pool_size
    end
  end
end
```

### 3. **Retry Pattern**
```ruby
class Retryable
  def self.with_retry(max_attempts: 3, backoff: :exponential)
    attempts = 0
    
    begin
      attempts += 1
      yield
    rescue => e
      if attempts < max_attempts
        sleep(calculate_backoff(attempts, backoff))
        retry
      else
        raise e
      end
    end
  end
  
  private
  
  def self.calculate_backoff(attempt, backoff_type)
    case backoff_type
    when :exponential
      2 ** attempt
    when :linear
      attempt
    when :fixed
      1
    end
  end
end
```

## Scalability Strategies

### 1. **Horizontal Scaling**
```
┌─────────┐    ┌─────────┐    ┌─────────┐
│ Server  │    │ Server  │    │ Server  │
│    1    │    │    2    │    │    3    │
└─────────┘    └─────────┘    └─────────┘
```

**Implementation:**
```ruby
# Load balancer configuration
upstream backend {
    server app1.example.com:3000;
    server app2.example.com:3000;
    server app3.example.com:3000;
}

# Application server configuration
# config/puma.rb
workers ENV.fetch("WEB_CONCURRENCY") { 2 }
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count
```

### 2. **Vertical Scaling**
```
┌─────────────────────────────────────┐
│           More Powerful             │
│              Server                 │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐   │
│  │ CPU │ │ RAM │ │ SSD │ │ GPU │   │
│  └─────┘ └─────┘ └─────┘ └─────┘   │
└─────────────────────────────────────┘
```

### 3. **Database Scaling**

**Read Replicas:**
```ruby
# config/database.yml
production:
  primary:
    adapter: postgresql
    database: myapp_production
    host: primary-db.example.com
  
  primary_replica:
    adapter: postgresql
    database: myapp_production
    host: replica-db.example.com
    replica: true

# Usage
class User < ApplicationRecord
  def self.find_with_replica(id)
    connected_to(role: :reading) do
      find(id)
    end
  end
end
```

**Database Sharding:**
```ruby
class User
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
```

### 4. **Caching Strategies**

**Multi-Level Caching:**
```ruby
class UserService
  def find_user(user_id)
    # L1: Application cache
    user = Rails.cache.read("user:#{user_id}")
    return user if user
    
    # L2: Database
    user = User.find(user_id)
    
    # Cache for future requests
    Rails.cache.write("user:#{user_id}", user, expires_in: 1.hour)
    
    user
  end
end
```

**CDN Caching:**
```ruby
class ApiController < ApplicationController
  def index
    @users = User.all
    
    if stale?(@users, public: true, last_modified: @users.maximum(:updated_at))
      render json: @users
    end
  end
end
```

## Performance Optimization

### 1. **Database Optimization**

**Query Optimization:**
```ruby
# Bad: N+1 queries
users = User.all
users.each { |user| puts user.orders.count }

# Good: Use includes
users = User.includes(:orders)
users.each { |user| puts user.orders.count }

# Better: Use counter cache
class Order < ApplicationRecord
  belongs_to :user, counter_cache: true
end
```

**Indexing:**
```ruby
# Add indexes for frequently queried columns
class AddIndexesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :email, unique: true
    add_index :users, [:first_name, :last_name]
    add_index :orders, [:user_id, :created_at]
  end
end
```

### 2. **Application Optimization**

**Connection Pooling:**
```ruby
# config/database.yml
production:
  adapter: postgresql
  database: myapp_production
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000
  checkout_timeout: 5
```

**Background Jobs:**
```ruby
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

### 3. **Caching Optimization**

**Fragment Caching:**
```erb
<% cache("users_index_#{User.maximum(:updated_at)}") do %>
  <h1>All Users</h1>
  <% @users.each do |user| %>
    <% cache(user) do %>
      <div class="user">
        <h3><%= user.name %></h3>
      </div>
    <% end %>
  <% end %>
<% end %>
```

**Low-Level Caching:**
```ruby
class User < ApplicationRecord
  def expensive_calculation
    Rails.cache.fetch("user_#{id}_expensive_calculation", expires_in: 1.hour) do
      # Expensive operation
      calculate_user_metrics
    end
  end
end
```

## Reliability & Fault Tolerance

### 1. **Health Checks**
```ruby
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
end
```

### 2. **Circuit Breaker**
```ruby
class CircuitBreaker
  def initialize(threshold: 5, timeout: 60)
    @threshold = threshold
    @timeout = timeout
    @failure_count = 0
    @last_failure_time = nil
    @state = :closed
  end
  
  def call(&block)
    case @state
    when :open
      if Time.current - @last_failure_time > @timeout
        @state = :half_open
      else
        raise "Circuit breaker is open"
      end
    end
    
    begin
      result = block.call
      on_success
      result
    rescue => e
      on_failure
      raise e
    end
  end
end
```

### 3. **Graceful Degradation**
```ruby
class UserService
  def get_user_with_fallback(user_id)
    begin
      # Try primary service
      get_user_from_primary_service(user_id)
    rescue => e
      Rails.logger.warn "Primary service failed: #{e.message}"
      
      begin
        # Try secondary service
        get_user_from_secondary_service(user_id)
      rescue => e2
        Rails.logger.error "Secondary service failed: #{e2.message}"
        
        # Return cached data or default
        get_cached_user(user_id) || create_default_user(user_id)
      end
    end
  end
end
```

## Security Considerations

### 1. **Authentication & Authorization**
```ruby
class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :authorize_action
  
  private
  
  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    
    begin
      decoded_token = JWT.decode(token, Rails.application.secrets.secret_key_base, true, { algorithm: 'HS256' })
      @current_user = User.find(decoded_token[0]['user_id'])
    rescue JWT::DecodeError
      render json: { error: 'Invalid token' }, status: :unauthorized
    end
  end
  
  def authorize_action
    unless @current_user&.can?(action_name, controller_name)
      render json: { error: 'Access denied' }, status: :forbidden
    end
  end
end
```

### 2. **Input Validation**
```ruby
class UserController < ApplicationController
  def create
    @user = User.new(user_params)
    
    if @user.save
      render json: @user, status: :created
    else
      render json: { errors: @user.errors }, status: :unprocessable_entity
    end
  end
  
  private
  
  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :password)
  end
end
```

### 3. **Rate Limiting**
```ruby
# config/initializers/rack_attack.rb
class Rack::Attack
  throttle('api/ip', limit: 100, period: 1.minute) do |req|
    req.ip if req.path.start_with?('/api/')
  end
  
  throttle('api/user', limit: 1000, period: 1.hour) do |req|
    req.env['rack.session']['user_id'] if req.path.start_with?('/api/')
  end
end
```

## Common System Design Problems

### 1. **Design a URL Shortener (like bit.ly)**

**Requirements:**
- Shorten long URLs
- Redirect to original URL
- Handle 100M URLs per day
- 5-year retention

**High-Level Design:**
```
Client → Load Balancer → Web Server → Application Server → Database
                                              ↓
                                        Cache (Redis)
```

**Implementation:**
```ruby
class UrlShortener
  BASE62_CHARS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
  
  def shorten(long_url)
    # Check if URL already exists
    existing = Url.find_by(long_url: long_url)
    return existing.short_url if existing
    
    # Create new short URL
    url = Url.create!(long_url: long_url)
    url.short_url = encode_base62(url.id)
    url.save!
    
    url.short_url
  end
  
  def expand(short_url)
    id = decode_base62(short_url)
    url = Url.find(id)
    url.long_url
  end
  
  private
  
  def encode_base62(number)
    result = ""
    while number > 0
      result = BASE62_CHARS[number % 62] + result
      number /= 62
    end
    result
  end
  
  def decode_base62(encoded)
    result = 0
    encoded.each_char do |char|
      result = result * 62 + BASE62_CHARS.index(char)
    end
    result
  end
end
```

### 2. **Design a Chat System (like WhatsApp)**

**Requirements:**
- 1:1 messaging
- Group messaging
- Message delivery status
- Handle 50M daily active users

**High-Level Design:**
```
Client → Load Balancer → Web Server → Message Service → Database
                                              ↓
                                        Message Queue
                                              ↓
                                        Push Notification Service
```

**Implementation:**
```ruby
class MessageService
  def send_message(sender_id, recipient_id, content, message_type = 'text')
    message = Message.create!(
      sender_id: sender_id,
      recipient_id: recipient_id,
      content: content,
      message_type: message_type,
      status: 'sent'
    )
    
    # Publish to message queue
    MessageQueue.publish('message.sent', {
      message_id: message.id,
      sender_id: sender_id,
      recipient_id: recipient_id,
      content: content
    })
    
    message
  end
  
  def get_messages(user_id, other_user_id, limit = 50)
    Message.where(
      "(sender_id = ? AND recipient_id = ?) OR (sender_id = ? AND recipient_id = ?)",
      user_id, other_user_id, other_user_id, user_id
    ).order(created_at: :desc).limit(limit)
  end
end

class MessageConsumer
  def process_message_sent(message)
    message_id = message[:message_id]
    recipient_id = message[:recipient_id]
    
    # Send push notification
    PushNotificationService.send_notification(recipient_id, message)
    
    # Update message status
    Message.find(message_id).update!(status: 'delivered')
  end
end
```

### 3. **Design a Social Media Feed (like Twitter)**

**Requirements:**
- Post tweets
- Follow users
- Timeline generation
- Handle 300M users

**High-Level Design:**
```
Client → Load Balancer → Web Server → Feed Service → Database
                                              ↓
                                        Cache (Redis)
                                              ↓
                                        Message Queue
```

**Implementation:**
```ruby
class FeedService
  def post_tweet(user_id, content)
    tweet = Tweet.create!(
      user_id: user_id,
      content: content,
      created_at: Time.current
    )
    
    # Fan-out to followers
    FanOutJob.perform_later(tweet.id)
    
    tweet
  end
  
  def get_timeline(user_id, limit = 20)
    # Try cache first
    timeline = Rails.cache.read("timeline:#{user_id}")
    
    if timeline.nil?
      # Generate timeline
      following_ids = Follow.where(follower_id: user_id).pluck(:following_id)
      timeline = Tweet.where(user_id: following_ids)
                     .order(created_at: :desc)
                     .limit(limit)
      
      # Cache for 5 minutes
      Rails.cache.write("timeline:#{user_id}", timeline, expires_in: 5.minutes)
    end
    
    timeline
  end
end

class FanOutJob < ApplicationJob
  def perform(tweet_id)
    tweet = Tweet.find(tweet_id)
    followers = Follow.where(following_id: tweet.user_id).pluck(:follower_id)
    
    followers.each do |follower_id|
      # Add to follower's timeline
      Rails.cache.delete("timeline:#{follower_id}")
    end
  end
end
```

## Interview Framework

### Step 1: Requirements Clarification
**Ask these questions:**
- What is the core functionality?
- How many users do we expect?
- What are the performance requirements?
- What are the constraints?
- What are the non-functional requirements?

### Step 2: High-Level Design
**Components to consider:**
- Load balancer
- Web servers
- Application servers
- Database
- Cache
- CDN
- Message queue

### Step 3: Detailed Design
**Focus areas:**
- Database schema
- API design
- Caching strategy
- Security considerations
- Monitoring and logging

### Step 4: Scale and Optimize
**Considerations:**
- Identify bottlenecks
- Implement caching
- Add read replicas
- Implement sharding
- Add monitoring

### Step 5: Handle Edge Cases
**Common edge cases:**
- High traffic spikes
- Database failures
- Network partitions
- Data consistency issues
- Security vulnerabilities

## Best Practices Summary

### Design Principles
1. **Start Simple**: Begin with basic design and iterate
2. **Think in Trade-offs**: Every decision has pros and cons
3. **Design for Failure**: Systems will fail, plan for it
4. **Measure Everything**: You can't optimize what you don't measure
5. **Keep It Simple**: Don't over-engineer

### Common Pitfalls
1. **Over-engineering**: Don't design for scale you don't need
2. **Single Point of Failure**: Always have redundancy
3. **Ignoring Security**: Consider authentication and authorization
4. **Poor Data Modeling**: Design database schema carefully
5. **No Monitoring**: Plan for observability from the start

### Interview Tips
1. **Ask Questions**: Clarify requirements before designing
2. **Think Out Loud**: Explain your thought process
3. **Start Simple**: Begin with basic design and iterate
4. **Consider Trade-offs**: Discuss pros and cons of decisions
5. **Be Realistic**: Design for actual scale, not theoretical limits

Remember: System design is about demonstrating your ability to think through complex problems, not about knowing every detail. Focus on the process and reasoning behind your decisions.

