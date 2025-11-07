# frozen_string_literal: true

# Concern for handling service object responses consistently
# Follows Single Responsibility Principle
module ServiceResponseHandler
  extend ActiveSupport::Concern

  private

  # Handle service response with automatic error handling
  # Usage: handle_service_response(service, success_message: 'Created successfully')
  def handle_service_response(service, options = {})
    success_message = options[:success_message] || 'Operation successful'
    error_message = options[:error_message] || 'Operation failed'
    presenter_class = options[:presenter]
    status = options[:status] || :ok

    if service.success?
      data = if presenter_class && service.respond_to?(:result)
               presenter_class.new(service.result).to_api_hash
             elsif service.respond_to?(:result)
               service.result
             else
               nil
             end

      render_success(data, success_message, status)
    else
      handle_service_errors(service, error_message)
    end
  end

  # Handle service errors consistently
  def handle_service_errors(service, error_message)
    if service.respond_to?(:last_error) && service.last_error.present?
      render_server_error(error_message, service.last_error)
    elsif service.respond_to?(:errors) && service.errors.any?
      render_validation_errors(service.errors.uniq, error_message)
    else
      render_error(error_message)
    end
  end
end

