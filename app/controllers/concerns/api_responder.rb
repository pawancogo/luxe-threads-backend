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

  def render_error(message = 'Error', errors = nil, status = :unprocessable_entity)
    response = {
      success: false,
      message: message,
      errors: errors
    }
    render json: response, status: status
  end

  def render_unauthorized(message = 'Unauthorized access')
    render_error(message, nil, :unauthorized)
  end

  def render_not_found(message = 'Resource not found')
    render_error(message, nil, :not_found)
  end

  def render_validation_errors(errors, message = 'Validation failed')
    render_error(message, errors, :unprocessable_entity)
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
    render_error(message, nil, :forbidden)
  end

  def render_conflict(message = 'Conflict', errors = nil)
    render_error(message, errors, :conflict)
  end

  def render_server_error(message = 'Internal server error')
    render_error(message, nil, :internal_server_error)
  end

  # Helper method to format validation errors
  def format_validation_errors(errors)
    if errors.is_a?(ActiveModel::Errors)
      errors.full_messages
    elsif errors.is_a?(Hash)
      errors.map { |field, messages| "#{field}: #{Array(messages).join(', ')}" }
    else
      Array(errors)
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





