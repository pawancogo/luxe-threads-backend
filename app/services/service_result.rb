# frozen_string_literal: true

# Value object for service results
# Follows Value Object pattern for consistent service responses
class ServiceResult
  attr_reader :data, :errors, :error, :success

  def initialize(success:, data: nil, errors: [], error: nil)
    @success = success
    @data = data
    @errors = Array(errors)
    @error = error
  end

  def success?
    @success && @errors.empty? && @error.nil?
  end

  def failure?
    !success?
  end

  # Factory methods
  def self.success(data = nil)
    new(success: true, data: data)
  end

  def self.failure(errors: [], error: nil)
    new(success: false, errors: errors, error: error)
  end

  def self.from_service(service)
    if service.success?
      success(service.result)
    else
      failure(errors: service.errors, error: service.last_error)
    end
  end
end

