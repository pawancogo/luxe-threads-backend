# frozen_string_literal: true

# Base service class following SOLID principles
# Provides common functionality for all services
class BaseService
  attr_reader :errors, :last_error

  def initialize(*args, **kwargs)
    @errors = []
    @last_error = nil
    @result = nil
  end

  # Main entry point - must be implemented by subclasses
  def call
    raise NotImplementedError, "#{self.class} must implement #call"
  end

  # Check if service execution was successful
  def success?
    @errors.empty? && @last_error.nil?
  end

  # Check if service execution failed
  def failure?
    !success?
  end

  # Get result (can be overridden by subclasses)
  def result
    @result
  end

  protected

  # Add error message
  def add_error(message)
    @errors << message unless @errors.include?(message)
  end

  # Add multiple errors
  def add_errors(messages)
    Array(messages).each { |msg| add_error(msg) }
  end

  # Set last error for debugging
  def set_last_error(error)
    @last_error = error
    Rails.logger.error "#{self.class} error: #{error.class} - #{error.message}"
    Rails.logger.error error.backtrace.join("\n") if error.respond_to?(:backtrace)
  end

  # Set result
  def set_result(value)
    @result = value
  end

  # Execute in transaction with error handling
  def with_transaction
    ActiveRecord::Base.transaction do
      yield
    end
  rescue ActiveRecord::RecordInvalid => e
    handle_record_invalid(e)
    raise
  rescue StandardError => e
    handle_error(e)
    raise
  end

  # Handle record invalid errors
  def handle_record_invalid(error)
    if error.record.respond_to?(:errors)
      add_errors(error.record.errors.full_messages)
    else
      add_error(error.message)
    end
    set_last_error(error)
  end

  # Handle general errors
  def handle_error(error)
    add_error(error.message)
    set_last_error(error)
  end

  # Log service execution
  def log_execution(action, details = {})
    Rails.logger.info "#{self.class} executing: #{action}"
    Rails.logger.debug "Details: #{details.inspect}" if details.any?
  end
end

