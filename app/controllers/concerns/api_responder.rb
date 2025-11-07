module ApiResponder
  extend ActiveSupport::Concern

  def render_success(data = nil, message = 'Success', status = :ok)
    response = {
      success: true,
      message: message,
      data: data
    }
    render json: response, status: status
  end

  def render_error(message = 'Error', errors = nil, status = :unprocessable_entity, error_code: nil)
    response = {
      success: false,
      message: message,
      errors: errors ? format_validation_errors(errors) : nil
    }
    
    # Add error code if provided
    response[:error_code] = error_code if error_code
    
    render json: response, status: status
  end

  def render_unauthorized(message = 'Unauthorized access')
    render_error(
      message,
      nil,
      :unauthorized,
      error_code: ErrorFormatter::ERROR_CODES[:unauthorized_access]
    )
  end

  def render_not_found(message = 'Resource not found')
    render_error(
      message,
      nil,
      :not_found,
      error_code: ErrorFormatter::ERROR_CODES[:not_found]
    )
  end

  def render_validation_errors(errors, message = 'Validation failed')
    render_error(
      message,
      errors,
      :unprocessable_entity,
      error_code: ErrorFormatter::ERROR_CODES[:validation_failed]
    )
  end

  def render_created(data = nil, message = 'Created successfully')
    render_success(data, message, :created)
  end

  def render_no_content(message = 'No content')
    render_success(nil, message, :no_content)
  end

  def render_bad_request(message = 'Bad request', errors = nil)
    render_error(message, errors, :bad_request)
  end

  def render_forbidden(message = 'Forbidden access')
    render_error(
      message,
      nil,
      :forbidden,
      error_code: ErrorFormatter::ERROR_CODES[:forbidden_access]
    )
  end

  def render_conflict(message = 'Conflict', errors = nil)
    render_error(
      message,
      errors,
      :conflict,
      error_code: ErrorFormatter::ERROR_CODES[:conflict]
    )
  end

  def render_server_error(message = 'Internal server error', error = nil)
    formatted = if error.present?
                  ErrorFormatter.format_server_error(error, message: message)
                else
                  {
                    code: ErrorFormatter::ERROR_CODES[:internal_error],
                    message: message,
                    errors: nil
                  }
                end
    
    response = {
      success: false,
      error_code: formatted[:code],
      message: formatted[:message],
      errors: formatted[:errors]
    }
    
    # Add error details in development/test
    if formatted[:details]
      response[:error_details] = formatted[:details]
    end
    
    # Log the error
    if error.present?
      Rails.logger.error "Server Error: #{error.class} - #{error.message}"
      Rails.logger.error error.backtrace.join("\n") if error.respond_to?(:backtrace)
    end
    
    render json: response, status: :internal_server_error
  end

  # Helper method to format validation errors (delegates to ErrorFormatter)
  def format_validation_errors(errors)
    ErrorFormatter.format_validation_errors(errors)
  end

  # Handle database constraint errors and convert to user-friendly messages
  def handle_constraint_error(error)
    formatted = ErrorFormatter.format_constraint_error(error)
    render_error(
      formatted[:message],
      formatted[:errors],
      status_for_code(formatted[:code])
    )
  end

  # Get HTTP status for error code
  def status_for_code(code)
    case code
    when ErrorFormatter::ERROR_CODES[:unique_constraint], ErrorFormatter::ERROR_CODES[:conflict]
      :conflict
    when ErrorFormatter::ERROR_CODES[:foreign_key_constraint], ErrorFormatter::ERROR_CODES[:not_null_constraint]
      :bad_request
    when ErrorFormatter::ERROR_CODES[:not_found]
      :not_found
    when ErrorFormatter::ERROR_CODES[:unauthorized_access]
      :unauthorized
    when ErrorFormatter::ERROR_CODES[:forbidden_access]
      :forbidden
    else
      :unprocessable_entity
    end
  end


  # Helper method to format model data
  def format_model_data(model, serializer = nil)
    if serializer
      serializer.new(model).as_json
    elsif model.respond_to?(:as_json)
      model.as_json
    else
      model
    end
  end

  # Helper method to format collection data
  def format_collection_data(collection, serializer = nil)
    if serializer
      collection.map { |item| serializer.new(item).as_json }
    elsif collection.respond_to?(:map)
      collection.map(&:as_json)
    else
      collection
    end
  end
end





