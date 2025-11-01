# API Responder Guide

## Overview
The `ApiResponder` concern provides a standardized way to handle JSON responses across all controllers in the LuxeThreads application.

## Usage

### Include the Concern
```ruby
class YourController < ApplicationController
  include ApiResponder
  # ... your controller code
end
```

### Available Methods

#### Success Responses
```ruby
# Basic success response
render_success(data, message, status)

# Created resource
render_created(data, message)

# No content (for DELETE operations)
render_no_content(message)
```

#### Error Responses
```ruby
# General error
render_error(message, errors, status)

# Unauthorized access
render_unauthorized(message)

# Resource not found
render_not_found(message)

# Validation errors
render_validation_errors(errors, message)

# Bad request
render_bad_request(message, errors)

# Forbidden access
render_forbidden(message)

# Conflict (e.g., duplicate resource)
render_conflict(message, errors)

# Server error
render_server_error(message)
```

### Response Format

All responses follow this standardized format:

#### Success Response
```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": {
    // Your data here
  }
}
```

#### Error Response
```json
{
  "success": false,
  "message": "Error description",
  "errors": [
    // Array of specific errors (optional)
  ]
}
```

### Helper Methods

#### Format Model Data
```ruby
# Format a single model instance
format_model_data(model, serializer = nil)

# Example
render_success(format_model_data(@user), 'User retrieved successfully')
```

#### Format Collection Data
```ruby
# Format a collection of models
format_collection_data(collection, serializer = nil)

# Example
render_success(format_collection_data(@users), 'Users retrieved successfully')
```

#### Format Validation Errors
```ruby
# Format validation errors consistently
format_validation_errors(errors)

# Example
render_validation_errors(@user.errors.full_messages, 'User creation failed')
```

### Examples

#### Authentication Controller
```ruby
def create
  @user = User.find_by_email(params[:email])
  if @user&.authenticate(params[:password])
    token = jwt_encode({ user_id: @user.id })
    user_data = {
      id: @user.id,
      email: @user.email,
      role: @user.role,
      email_verified: @user.email_verified?
    }
    render_success({ token: token, user: user_data }, 'Login successful')
  else
    render_unauthorized('Invalid email or password')
  end
end
```

#### CRUD Operations
```ruby
# Create
def create
  @product = Product.new(product_params)
  if @product.save
    render_created(format_model_data(@product), 'Product created successfully')
  else
    render_validation_errors(@product.errors.full_messages, 'Product creation failed')
  end
end

# Read
def show
  render_success(format_model_data(@product), 'Product retrieved successfully')
end

# Update
def update
  if @product.update(product_params)
    render_success(format_model_data(@product), 'Product updated successfully')
  else
    render_validation_errors(@product.errors.full_messages, 'Product update failed')
  end
end

# Delete
def destroy
  @product.destroy
  render_no_content('Product deleted successfully')
end
```

### Migration from Old Format

#### Before (Old Format)
```ruby
render json: { token: token }, status: :ok
render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
render json: { error: 'unauthorized' }, status: :unauthorized
```

#### After (New Format)
```ruby
render_success({ token: token }, 'Login successful')
render_validation_errors(@user.errors.full_messages, 'User creation failed')
render_unauthorized('Invalid credentials')
```

### Status Codes

The responder automatically sets appropriate HTTP status codes:

- `render_success` → 200 OK
- `render_created` → 201 Created
- `render_no_content` → 204 No Content
- `render_unauthorized` → 401 Unauthorized
- `render_not_found` → 404 Not Found
- `render_validation_errors` → 422 Unprocessable Entity
- `render_bad_request` → 400 Bad Request
- `render_forbidden` → 403 Forbidden
- `render_conflict` → 409 Conflict
- `render_server_error` → 500 Internal Server Error

### Benefits

1. **Consistency**: All API responses follow the same format
2. **Maintainability**: Easy to update response format across the entire application
3. **Developer Experience**: Clear, predictable API responses
4. **Error Handling**: Standardized error response format
5. **Documentation**: Self-documenting response structure





