# frozen_string_literal: true

# Error Formatter Service
# Standardizes error messages and formats
# Follows DRY principle
class ErrorFormatter
  # Error codes for consistent error identification
  ERROR_CODES = {
    # Authentication & Authorization
    authentication_required: 'AUTH_001',
    authentication_failed: 'AUTH_002',
    token_expired: 'AUTH_003',
    token_invalid: 'AUTH_004',
    unauthorized_access: 'AUTH_005',
    forbidden_access: 'AUTH_006',
    
    # Validation
    validation_failed: 'VAL_001',
    required_field_missing: 'VAL_002',
    invalid_format: 'VAL_003',
    out_of_range: 'VAL_004',
    
    # Resource
    not_found: 'RES_001',
    already_exists: 'RES_002',
    conflict: 'RES_003',
    
    # Database
    constraint_violation: 'DB_001',
    unique_constraint: 'DB_002',
    foreign_key_constraint: 'DB_003',
    not_null_constraint: 'DB_004',
    
    # Business Logic
    insufficient_stock: 'BIZ_001',
    invalid_state: 'BIZ_002',
    operation_not_allowed: 'BIZ_003',
    
    # Server
    internal_error: 'SRV_001',
    service_unavailable: 'SRV_002',
    timeout: 'SRV_003'
  }.freeze

  class << self
    # Format validation errors from ActiveModel::Errors
    def format_validation_errors(errors)
      return [] if errors.blank?
      
      if errors.is_a?(ActiveModel::Errors)
        errors.full_messages.map { |msg| format_message(msg) }
      elsif errors.is_a?(Hash)
        errors.flat_map do |field, messages|
          Array(messages).map { |msg| format_field_error(field, msg) }
        end
      elsif errors.is_a?(Array)
        errors.map { |msg| format_message(msg) }
      else
        [format_message(errors.to_s)]
      end
    end

    # Format a single error message
    def format_message(message)
      message.to_s.strip
    end

    # Format field-specific error
    def format_field_error(field, message)
      field_name = field.to_s.humanize
      "#{field_name}: #{format_message(message)}"
    end

    # Format error response
    def format_error_response(code:, message:, errors: nil, details: nil)
      response = {
        success: false,
        error_code: code,
        message: format_message(message),
        errors: errors ? format_validation_errors(errors) : nil
      }
      
      # Add details in development/test
      if details && (Rails.env.development? || Rails.env.test?)
        response[:details] = details
      end
      
      response
    end

    # Format constraint error
    def format_constraint_error(error)
      message = error.message.to_s.downcase
      
      if message.include?('unique constraint') || message.include?('uniqueness violation')
        format_unique_constraint_error(error)
      elsif message.include?('foreign key constraint') || message.include?('foreign key violation')
        format_foreign_key_constraint_error(error)
      elsif message.include?('not null constraint') || message.include?('may not be null')
        format_not_null_constraint_error(error)
      else
        format_generic_constraint_error(error)
      end
    end

    # Extract field name from constraint error
    def extract_field_from_constraint(message)
      # Try to extract field name from various error formats
      if match = message.match(/\((\w+)\)/i)
        match[1]
      elsif match = message.match(/column\s+['"]?(\w+)/i)
        match[1]
      elsif match = message.match(/index\s+['"]?(\w+)/i)
        match[1]
      else
        'field'
      end
    end

    # Format unique constraint error
    def format_unique_constraint_error(error)
      message = error.message.to_s
      field = extract_field_from_constraint(message)
      
      user_message = case field.downcase
      when /email/i
        'This email is already registered'
      when /phone/i
        'This phone number is already registered'
      when /gst/i
        'This GST number is already registered'
      when /sku/i
        'This SKU already exists'
      when /slug/i
        'This slug is already in use'
      else
        "#{field.humanize} must be unique"
      end
      
      {
        code: ERROR_CODES[:unique_constraint],
        message: user_message,
        errors: ["#{field}: has already been taken"]
      }
    end

    # Format foreign key constraint error
    def format_foreign_key_constraint_error(error)
      {
        code: ERROR_CODES[:foreign_key_constraint],
        message: 'Referenced record does not exist',
        errors: ['The associated record could not be found']
      }
    end

    # Format not null constraint error
    def format_not_null_constraint_error(error)
      field = extract_field_from_constraint(error.message)
      {
        code: ERROR_CODES[:not_null_constraint],
        message: 'Required field missing',
        errors: ["#{field.humanize}: cannot be blank"]
      }
    end

    # Format generic constraint error
    def format_generic_constraint_error(error)
      {
        code: ERROR_CODES[:constraint_violation],
        message: 'Database constraint violation',
        errors: ['An error occurred while processing your request']
      }
    end

    # Format server error
    def format_server_error(error, message: 'Internal server error')
      response = {
        code: ERROR_CODES[:internal_error],
        message: message,
        errors: nil
      }
      
      # Add error details in development/test
      if Rails.env.development? || Rails.env.test?
        response[:details] = {
          class: error.class.name,
          message: error.message,
          backtrace: error.backtrace&.first(10) # Limit backtrace
        }
      end
      
      response
    end
  end
end

