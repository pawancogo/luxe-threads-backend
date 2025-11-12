# frozen_string_literal: true

# Service for bulk deletion operations
# Handles deletion of multiple records with proper error handling and reporting
class BulkDeletionService < BaseService
  attr_reader :model_class, :deleted_count, :failed_count

  def initialize(model_class)
    super()
    @model_class = model_class
    @deleted_count = 0
    @failed_count = 0
  end

  def call(ids)
    validate_ids!(ids)

    # Process each deletion individually (no transaction) to allow partial success
    ids.each do |id|
      delete_record(id)
    end

    set_result(build_result)
    self
  rescue ArgumentError => e
    add_error(e.message)
    set_result(build_result)
    self
  end

  # Backward compatibility - alias for call
  def delete(ids)
    call(ids)
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
    add_error("Record #{id}: #{error_message}")
  end

  def handle_not_found(id)
    @failed_count += 1
    add_error("Record #{id}: not found")
  end

  def handle_constraint_error(id, error)
    @failed_count += 1
    add_error("Record #{id}: cannot be deleted due to existing references")
    set_last_error(error)
  end

  def handle_generic_error(id, error)
    @failed_count += 1
    add_error("Record #{id}: #{error.message}")
    set_last_error(error)
  end

  def build_result
    {
      deleted_count: @deleted_count,
      failed_count: @failed_count,
      errors: errors,
      success: success?,
      partial_success: partial_success?
    }
  end
end


