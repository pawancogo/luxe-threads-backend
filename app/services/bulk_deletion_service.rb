# frozen_string_literal: true

# Service for bulk deletion operations
# Handles deletion of multiple records with proper error handling and reporting
class BulkDeletionService
  attr_reader :model_class, :errors, :deleted_count, :failed_count

  def initialize(model_class)
    @model_class = model_class
    @errors = []
    @deleted_count = 0
    @failed_count = 0
  end

  def delete(ids)
    validate_ids!(ids)

    ids.each do |id|
      delete_record(id)
    end

    build_result
  end

  def success?
    @failed_count.zero?
  end

  def partial_success?
    @deleted_count.positive? && @failed_count.positive?
  end

  private

  def validate_ids!(ids)
    unless ids.is_a?(Array) && ids.any?
      raise ArgumentError, 'IDs must be a non-empty array'
    end
  end

  def delete_record(id)
    record = @model_class.find(id)
    
    if record.destroy
      @deleted_count += 1
    else
      handle_deletion_failure(id, record)
    end
  rescue ActiveRecord::RecordNotFound
    handle_not_found(id)
  rescue ActiveRecord::StatementInvalid, ActiveRecord::InvalidForeignKey => e
    handle_constraint_error(id, e)
  rescue StandardError => e
    handle_generic_error(id, e)
  end

  def handle_deletion_failure(id, record)
    @failed_count += 1
    error_message = record.errors.full_messages.any? ? 
                    record.errors.full_messages.join(', ') : 
                    'Deletion failed'
    @errors << "Record #{id}: #{error_message}"
  end

  def handle_not_found(id)
    @failed_count += 1
    @errors << "Record #{id}: not found"
  end

  def handle_constraint_error(id, error)
    @failed_count += 1
    @errors << "Record #{id}: cannot be deleted due to existing references"
    Rails.logger.error "Constraint error deleting #{@model_class.name} #{id}: #{error.message}"
  end

  def handle_generic_error(id, error)
    @failed_count += 1
    @errors << "Record #{id}: #{error.message}"
    Rails.logger.error "Error deleting #{@model_class.name} #{id}: #{error.message}"
    Rails.logger.error error.backtrace.join("\n") if error.backtrace
  end

  def build_result
    {
      deleted_count: @deleted_count,
      failed_count: @failed_count,
      errors: @errors,
      success: success?,
      partial_success: partial_success?
    }
  end
end


