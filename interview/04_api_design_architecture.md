# API Design & Architecture Guide

## Table of Contents
1. [API Design Principles](#api-design-principles)
2. [RESTful API Design](#restful-api-design)
3. [API Versioning](#api-versioning)
4. [Authentication & Authorization](#authentication--authorization)
5. [Error Handling](#error-handling)
6. [API Documentation](#api-documentation)
7. [Performance & Optimization](#performance--optimization)
8. [Security Best Practices](#security-best-practices)
9. [Common Interview Questions](#common-interview-questions)

## API Design Principles

### Core Principles
1. **Consistency**: Uniform patterns across all endpoints
2. **Simplicity**: Easy to understand and use
3. **Predictability**: Expected behavior and responses
4. **Flexibility**: Support for various use cases
5. **Scalability**: Handle growth and changes
6. **Security**: Protect data and resources

### Design Philosophy
- **Resource-Oriented**: Focus on resources, not actions
- **Stateless**: Each request contains all necessary information
- **Cacheable**: Responses can be cached when appropriate
- **Layered**: Client doesn't need to know about server architecture

## RESTful API Design

### HTTP Methods & Their Usage

#### GET - Retrieve Resources
```http
GET /api/v1/users
GET /api/v1/users/123
GET /api/v1/users/123/orders
```

**Characteristics:**
- Idempotent (safe to repeat)
- Cacheable
- No request body
- Returns data

#### POST - Create Resources
```http
POST /api/v1/users
Content-Type: application/json

{
  "user": {
    "email": "john@example.com",
    "first_name": "John",
    "last_name": "Doe"
  }
}
```

**Characteristics:**
- Not idempotent
- Creates new resources
- Returns created resource
- Status code: 201 Created

#### PUT - Update/Replace Resources
```http
PUT /api/v1/users/123
Content-Type: application/json

{
  "user": {
    "email": "john.doe@example.com",
    "first_name": "John",
    "last_name": "Doe"
  }
}
```

**Characteristics:**
- Idempotent
- Complete resource replacement
- Status code: 200 OK or 204 No Content

#### PATCH - Partial Update
```http
PATCH /api/v1/users/123
Content-Type: application/json

{
  "user": {
    "first_name": "Johnny"
  }
}
```

**Characteristics:**
- Idempotent
- Partial resource update
- Status code: 200 OK

#### DELETE - Remove Resources
```http
DELETE /api/v1/users/123
```

**Characteristics:**
- Idempotent
- Removes resource
- Status code: 204 No Content

### URL Design Patterns

#### Resource Naming
```http
# Good: Use nouns, not verbs
GET /api/v1/users
POST /api/v1/users
GET /api/v1/users/123

# Bad: Using verbs
GET /api/v1/getUsers
POST /api/v1/createUser
```

#### Hierarchical Resources
```http
# Users and their orders
GET /api/v1/users/123/orders
POST /api/v1/users/123/orders
GET /api/v1/users/123/orders/456

# Nested resources
GET /api/v1/users/123/orders/456/items
POST /api/v1/users/123/orders/456/items
```

#### Query Parameters
```http
# Filtering
GET /api/v1/users?active=true&role=admin

# Pagination
GET /api/v1/users?page=2&per_page=20

# Sorting
GET /api/v1/users?sort=created_at&order=desc

# Searching
GET /api/v1/users?search=john&fields=name,email
```

### Response Formats

#### Standard Response Structure
```json
{
  "data": {
    "id": 123,
    "type": "user",
    "attributes": {
      "email": "john@example.com",
      "first_name": "John",
      "last_name": "Doe",
      "created_at": "2023-01-01T00:00:00Z",
      "updated_at": "2023-01-01T00:00:00Z"
    },
    "relationships": {
      "orders": {
        "data": [
          { "id": 456, "type": "order" }
        ]
      }
    }
  },
  "meta": {
    "total_count": 1,
    "page": 1,
    "per_page": 20
  },
  "links": {
    "self": "/api/v1/users/123",
    "orders": "/api/v1/users/123/orders"
  }
}
```

#### Collection Response
```json
{
  "data": [
    {
      "id": 123,
      "type": "user",
      "attributes": {
        "email": "john@example.com",
        "first_name": "John",
        "last_name": "Doe"
      }
    },
    {
      "id": 124,
      "type": "user",
      "attributes": {
        "email": "jane@example.com",
        "first_name": "Jane",
        "last_name": "Smith"
      }
    }
  ],
  "meta": {
    "total_count": 2,
    "page": 1,
    "per_page": 20,
    "total_pages": 1
  },
  "links": {
    "self": "/api/v1/users?page=1",
    "first": "/api/v1/users?page=1",
    "last": "/api/v1/users?page=1"
  }
}
```

## API Versioning

### Versioning Strategies

#### URL Path Versioning
```http
GET /api/v1/users
GET /api/v2/users
```

**Pros:**
- Clear and explicit
- Easy to implement
- Cacheable

**Cons:**
- URL pollution
- Breaking changes require new URLs

#### Header Versioning
```http
GET /api/users
Accept: application/vnd.api+json;version=1
```

**Pros:**
- Clean URLs
- Flexible versioning

**Cons:**
- Less discoverable
- Caching complexity

#### Query Parameter Versioning
```http
GET /api/users?version=1
```

**Pros:**
- Simple to implement
- Backward compatible

**Cons:**
- Not RESTful
- Caching issues

### Versioning Implementation

#### Rails API Versioning
```ruby
# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users
    end
    
    namespace :v2 do
      resources :users
    end
  end
end

# app/controllers/api/v1/users_controller.rb
class Api::V1::UsersController < ApplicationController
  def index
    @users = User.all
    render json: @users
  end
end

# app/controllers/api/v2/users_controller.rb
class Api::V2::UsersController < ApplicationController
  def index
    @users = User.includes(:profile, :orders)
    render json: @users, include: [:profile, :orders]
  end
end
```

#### Version Detection
```ruby
class ApplicationController < ActionController::API
  before_action :set_api_version
  
  private
  
  def set_api_version
    @api_version = request.headers['Accept']&.match(/version=(\d+)/)&.[](1) || '1'
  end
end
```

## Authentication & Authorization

### Authentication Methods

#### API Key Authentication
```http
GET /api/v1/users
X-API-Key: your-api-key-here
```

**Implementation:**
```ruby
class ApplicationController < ActionController::API
  before_action :authenticate_api_key
  
  private
  
  def authenticate_api_key
    api_key = request.headers['X-API-Key']
    @current_user = User.find_by(api_key: api_key)
    
    unless @current_user
      render json: { error: 'Invalid API key' }, status: :unauthorized
    end
  end
end
```

#### JWT (JSON Web Token) Authentication
```http
GET /api/v1/users
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Implementation:**
```ruby
# Gemfile
gem 'jwt'

# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  before_action :authenticate_jwt
  
  private
  
  def authenticate_jwt
    token = request.headers['Authorization']&.split(' ')&.last
    
    begin
      decoded_token = JWT.decode(token, Rails.application.secrets.secret_key_base, true, { algorithm: 'HS256' })
      @current_user = User.find(decoded_token[0]['user_id'])
    rescue JWT::DecodeError
      render json: { error: 'Invalid token' }, status: :unauthorized
    end
  end
end

# app/controllers/api/v1/authentication_controller.rb
class Api::V1::AuthenticationController < ApplicationController
  def create
    user = User.find_by(email: params[:email])
    
    if user&.authenticate(params[:password])
      token = JWT.encode({ user_id: user.id }, Rails.application.secrets.secret_key_base, 'HS256')
      render json: { token: token, user: user }
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end
end
```

#### OAuth 2.0
```ruby
# Gemfile
gem 'omniauth'
gem 'omniauth-google-oauth2'

# config/initializers/omniauth.rb
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET']
end

# app/controllers/api/v1/oauth_controller.rb
class Api::V1::OauthController < ApplicationController
  def google
    auth = request.env['omniauth.auth']
    user = User.find_or_create_by(email: auth.info.email) do |u|
      u.first_name = auth.info.first_name
      u.last_name = auth.info.last_name
    end
    
    token = JWT.encode({ user_id: user.id }, Rails.application.secrets.secret_key_base, 'HS256')
    render json: { token: token, user: user }
  end
end
```

### Authorization Patterns

#### Role-Based Access Control (RBAC)
```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_many :user_roles
  has_many :roles, through: :user_roles
  
  def has_role?(role_name)
    roles.exists?(name: role_name)
  end
  
  def admin?
    has_role?('admin')
  end
  
  def can?(action, resource)
    # Check permissions based on roles
    roles.joins(:permissions).where(permissions: { action: action, resource: resource }).exists?
  end
end

# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  before_action :authorize_action
  
  private
  
  def authorize_action
    unless @current_user&.can?(action_name, controller_name)
      render json: { error: 'Access denied' }, status: :forbidden
    end
  end
end
```

#### Policy-Based Authorization
```ruby
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

# app/controllers/api/v1/users_controller.rb
class Api::V1::UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    authorize @user
    
    render json: @user
  end
end
```

## Error Handling

### HTTP Status Codes

#### Success Codes
- **200 OK**: Request successful
- **201 Created**: Resource created
- **204 No Content**: Request successful, no content returned

#### Client Error Codes
- **400 Bad Request**: Invalid request
- **401 Unauthorized**: Authentication required
- **403 Forbidden**: Access denied
- **404 Not Found**: Resource not found
- **422 Unprocessable Entity**: Validation errors

#### Server Error Codes
- **500 Internal Server Error**: Server error
- **502 Bad Gateway**: Upstream server error
- **503 Service Unavailable**: Service temporarily unavailable

### Error Response Format
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "The request contains invalid data",
    "details": [
      {
        "field": "email",
        "message": "Email is required"
      },
      {
        "field": "password",
        "message": "Password must be at least 8 characters"
      }
    ]
  },
  "meta": {
    "request_id": "req_123456789",
    "timestamp": "2023-01-01T00:00:00Z"
  }
}
```

### Error Handling Implementation
```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :validation_error
  rescue_from StandardError, with: :internal_error
  
  private
  
  def not_found(exception)
    render json: {
      error: {
        code: 'NOT_FOUND',
        message: 'Resource not found',
        details: exception.message
      }
    }, status: :not_found
  end
  
  def validation_error(exception)
    render json: {
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Validation failed',
        details: exception.record.errors.full_messages
      }
    }, status: :unprocessable_entity
  end
  
  def internal_error(exception)
    Rails.logger.error "Internal error: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")
    
    render json: {
      error: {
        code: 'INTERNAL_ERROR',
        message: 'An internal error occurred'
      }
    }, status: :internal_server_error
  end
end
```

## API Documentation

### OpenAPI/Swagger Specification
```yaml
# swagger.yaml
openapi: 3.0.0
info:
  title: User API
  version: 1.0.0
  description: API for managing users

paths:
  /api/v1/users:
    get:
      summary: List users
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
        - name: per_page
          in: query
          schema:
            type: integer
            default: 20
      responses:
        '200':
          description: List of users
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: array
                    items:
                      $ref: '#/components/schemas/User'
    
    post:
      summary: Create user
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'
      responses:
        '201':
          description: User created
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'

components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: integer
        email:
          type: string
          format: email
        first_name:
          type: string
        last_name:
          type: string
        created_at:
          type: string
          format: date-time
    
    CreateUserRequest:
      type: object
      required:
        - email
        - first_name
        - last_name
      properties:
        email:
          type: string
          format: email
        first_name:
          type: string
        last_name:
          type: string
```

### Rails API Documentation
```ruby
# Gemfile
gem 'rspec_api_documentation'
gem 'swagger-docs'

# spec/acceptance/users_spec.rb
require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Users' do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'
  
  get '/api/v1/users' do
    parameter :page, 'Page number', type: :integer
    parameter :per_page, 'Items per page', type: :integer
    
    let(:page) { 1 }
    let(:per_page) { 20 }
    
    example 'List users' do
      do_request
      
      expect(status).to eq(200)
      expect(response_body).to include('data')
    end
  end
  
  post '/api/v1/users' do
    parameter :email, 'User email', required: true
    parameter :first_name, 'First name', required: true
    parameter :last_name, 'Last name', required: true
    
    let(:email) { 'john@example.com' }
    let(:first_name) { 'John' }
    let(:last_name) { 'Doe' }
    
    example 'Create user' do
      do_request
      
      expect(status).to eq(201)
      expect(response_body).to include('id')
    end
  end
end
```

## Performance & Optimization

### Caching Strategies

#### HTTP Caching
```ruby
# app/controllers/api/v1/users_controller.rb
class Api::V1::UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    
    if stale?(@user)
      render json: @user
    end
  end
  
  def index
    @users = User.all
    
    if stale?(@users)
      render json: @users
    end
  end
end
```

#### Application Caching
```ruby
# app/controllers/api/v1/users_controller.rb
class Api::V1::UsersController < ApplicationController
  def show
    @user = Rails.cache.fetch("user_#{params[:id]}", expires_in: 1.hour) do
      User.find(params[:id])
    end
    
    render json: @user
  end
end
```

### Pagination
```ruby
# app/controllers/api/v1/users_controller.rb
class Api::V1::UsersController < ApplicationController
  def index
    page = params[:page]&.to_i || 1
    per_page = params[:per_page]&.to_i || 20
    per_page = [per_page, 100].min  # Limit max per_page
    
    @users = User.page(page).per(per_page)
    
    render json: {
      data: @users,
      meta: {
        current_page: @users.current_page,
        total_pages: @users.total_pages,
        total_count: @users.total_count,
        per_page: @users.limit_value
      }
    }
  end
end
```

### Rate Limiting
```ruby
# Gemfile
gem 'rack-attack'

# config/initializers/rack_attack.rb
class Rack::Attack
  # Allow requests from localhost
  safelist('allow-localhost') do |req|
    '127.0.0.1' == req.ip || '::1' == req.ip
  end
  
  # Rate limit API requests
  throttle('api/ip', limit: 100, period: 1.minute) do |req|
    req.ip if req.path.start_with?('/api/')
  end
  
  # Rate limit by user
  throttle('api/user', limit: 1000, period: 1.hour) do |req|
    req.env['rack.session']['user_id'] if req.path.start_with?('/api/')
  end
end

# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  before_action :check_rate_limit
  
  private
  
  def check_rate_limit
    if Rack::Attack.throttled?(request)
      render json: { error: 'Rate limit exceeded' }, status: :too_many_requests
    end
  end
end
```

## Security Best Practices

### Input Validation
```ruby
# app/controllers/api/v1/users_controller.rb
class Api::V1::UsersController < ApplicationController
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

### SQL Injection Prevention
```ruby
# Good: Parameterized queries
User.where("email = ?", params[:email])
User.where(email: params[:email])

# Bad: String interpolation
User.where("email = '#{params[:email]}'")
```

### CORS Configuration
```ruby
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'https://yourdomain.com', 'https://app.yourdomain.com'
    
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
```

### HTTPS Enforcement
```ruby
# config/environments/production.rb
Rails.application.configure do
  config.force_ssl = true
end
```

## Common Interview Questions

### 1. Design a RESTful API for a Blog System
**Requirements:**
- Users, Posts, Comments, Categories
- Authentication required for creating/updating
- Public read access

**API Design:**
```http
# Users
GET    /api/v1/users
POST   /api/v1/users
GET    /api/v1/users/:id
PUT    /api/v1/users/:id
DELETE /api/v1/users/:id

# Posts
GET    /api/v1/posts
POST   /api/v1/posts
GET    /api/v1/posts/:id
PUT    /api/v1/posts/:id
DELETE /api/v1/posts/:id

# Comments
GET    /api/v1/posts/:post_id/comments
POST   /api/v1/posts/:post_id/comments
GET    /api/v1/comments/:id
PUT    /api/v1/comments/:id
DELETE /api/v1/comments/:id

# Categories
GET    /api/v1/categories
POST   /api/v1/categories
GET    /api/v1/categories/:id
PUT    /api/v1/categories/:id
DELETE /api/v1/categories/:id
```

### 2. How do you handle API versioning?
**Answer:**
1. **URL Path Versioning**: `/api/v1/users`, `/api/v2/users`
2. **Header Versioning**: `Accept: application/vnd.api+json;version=1`
3. **Query Parameter**: `/api/users?version=1`

**Implementation:**
```ruby
# config/routes.rb
namespace :api do
  namespace :v1 do
    resources :users
  end
  
  namespace :v2 do
    resources :users
  end
end
```

### 3. Explain JWT Authentication
**Answer:**
JWT (JSON Web Token) is a stateless authentication method.

**Structure:**
- Header: Algorithm and token type
- Payload: Claims (user data)
- Signature: Verification

**Implementation:**
```ruby
# Encoding
token = JWT.encode({ user_id: user.id }, secret_key, 'HS256')

# Decoding
decoded = JWT.decode(token, secret_key, true, { algorithm: 'HS256' })
user_id = decoded[0]['user_id']
```

### 4. How do you handle API errors?
**Answer:**
1. **Consistent Error Format**: Standard error response structure
2. **Appropriate HTTP Status Codes**: 400, 401, 403, 404, 422, 500
3. **Detailed Error Messages**: Helpful error descriptions
4. **Error Logging**: Track and monitor errors

**Example:**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": ["Email is required", "Password too short"]
  }
}
```

### 5. Design API for E-commerce System
**Requirements:**
- Products, Categories, Users, Orders, Cart
- Authentication for orders
- Public product browsing

**API Endpoints:**
```http
# Products
GET    /api/v1/products
GET    /api/v1/products/:id
GET    /api/v1/categories/:id/products

# Categories
GET    /api/v1/categories

# Cart (authenticated)
GET    /api/v1/cart
POST   /api/v1/cart/items
PUT    /api/v1/cart/items/:id
DELETE /api/v1/cart/items/:id

# Orders (authenticated)
GET    /api/v1/orders
POST   /api/v1/orders
GET    /api/v1/orders/:id
```

### 6. How do you implement rate limiting?
**Answer:**
1. **IP-based limiting**: Limit requests per IP
2. **User-based limiting**: Limit requests per user
3. **Endpoint-specific**: Different limits for different endpoints

**Implementation:**
```ruby
# Using rack-attack
throttle('api/ip', limit: 100, period: 1.minute) do |req|
  req.ip if req.path.start_with?('/api/')
end
```

### 7. Explain API caching strategies
**Answer:**
1. **HTTP Caching**: ETags, Last-Modified headers
2. **Application Caching**: Redis, Memcached
3. **CDN Caching**: Static content delivery

**Implementation:**
```ruby
# HTTP caching
if stale?(@user)
  render json: @user
end

# Application caching
@user = Rails.cache.fetch("user_#{params[:id]}", expires_in: 1.hour) do
  User.find(params[:id])
end
```

### 8. How do you handle API pagination?
**Answer:**
1. **Offset-based**: `?page=2&per_page=20`
2. **Cursor-based**: `?cursor=abc123&limit=20`
3. **Keyset pagination**: `?since_id=123&limit=20`

**Implementation:**
```ruby
def index
  page = params[:page]&.to_i || 1
  per_page = params[:per_page]&.to_i || 20
  
  @users = User.page(page).per(per_page)
  
  render json: {
    data: @users,
    meta: {
      current_page: @users.current_page,
      total_pages: @users.total_pages,
      total_count: @users.total_count
    }
  }
end
```

### 9. Design API for Real-time Chat
**Requirements:**
- WebSocket connection
- Message history
- User presence
- Room management

**API Design:**
```http
# REST endpoints
GET    /api/v1/rooms
POST   /api/v1/rooms
GET    /api/v1/rooms/:id/messages
POST   /api/v1/rooms/:id/messages

# WebSocket events
# Client → Server
{
  "type": "join_room",
  "room_id": "123"
}

{
  "type": "send_message",
  "room_id": "123",
  "content": "Hello!"
}

# Server → Client
{
  "type": "message",
  "room_id": "123",
  "user_id": "456",
  "content": "Hello!",
  "timestamp": "2023-01-01T00:00:00Z"
}
```

### 10. How do you ensure API security?
**Answer:**
1. **Authentication**: JWT, API keys, OAuth
2. **Authorization**: Role-based access control
3. **Input Validation**: Sanitize and validate input
4. **HTTPS**: Encrypt all communication
5. **Rate Limiting**: Prevent abuse
6. **CORS**: Control cross-origin requests

**Implementation:**
```ruby
# Authentication
before_action :authenticate_user!

# Authorization
before_action :authorize_action

# Input validation
def user_params
  params.require(:user).permit(:email, :first_name, :last_name)
end

# Rate limiting
throttle('api/ip', limit: 100, period: 1.minute)
```

## Best Practices Summary

### Design Principles
1. **RESTful**: Use HTTP methods correctly
2. **Consistent**: Uniform patterns across endpoints
3. **Stateless**: Each request is independent
4. **Cacheable**: Design for caching
5. **Layered**: Hide implementation details

### Security
1. **Authentication**: Verify user identity
2. **Authorization**: Control access to resources
3. **Input Validation**: Sanitize all input
4. **HTTPS**: Encrypt communication
5. **Rate Limiting**: Prevent abuse

### Performance
1. **Caching**: Implement multiple caching layers
2. **Pagination**: Handle large datasets
3. **Compression**: Reduce payload size
4. **CDN**: Use content delivery networks
5. **Monitoring**: Track performance metrics

### Documentation
1. **OpenAPI**: Use standard documentation format
2. **Examples**: Provide request/response examples
3. **Error Codes**: Document all error scenarios
4. **Versioning**: Document version changes
5. **Testing**: Include test examples

Remember: Good API design is about creating an interface that is intuitive, consistent, and efficient for developers to use. Focus on the developer experience and make your API easy to understand and integrate with.



