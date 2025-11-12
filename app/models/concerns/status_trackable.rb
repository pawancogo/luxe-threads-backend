# frozen_string_literal: true

# Concern for models that track status history
# Provides JSON-based status history tracking with timestamps
module StatusTrackable
  extend ActiveSupport::Concern

  included do
    # Ensure status_history column exists (JSON or text)
    # Ensure status_updated_at column exists (datetime)
  end

  # Parse status history JSON
  def status_history_array
    return [] if status_history.blank?
    JSON.parse(status_history) rescue []
  end

  # Set status history from array
  def status_history_array=(data)
    self.status_history = data.to_json
  end

  # Add status to history
  # Supports both positional and keyword arguments for backward compatibility
  def add_status_to_history(new_status, notes_or_options = nil, metadata: {})
    # Handle both positional notes and keyword arguments
    if notes_or_options.is_a?(Hash)
      notes = notes_or_options[:notes]
      metadata = notes_or_options[:metadata] || metadata
    else
      notes = notes_or_options
    end

    history = status_history_array
    history << {
      'status' => new_status.to_s,
      'timestamp' => Time.current.iso8601,
      'notes' => notes,
      'metadata' => metadata
    }
    self.status_history_array = history
    
    # NOTE: Using update_column here to avoid infinite callback loops
    # This method is called from after_update callbacks, so using update! would
    # trigger another update cycle. This is an intentional bypass for status_history
    # tracking only. All other updates should use save/update/update! to trigger validations.
    if persisted?
      update_column(:status_history, status_history)
      update_column(:status_updated_at, Time.current) if respond_to?(:status_updated_at=)
    end
  end

  # Update status history (for callbacks)
  def update_status_history
    return unless respond_to?(:status) && status.present?
    add_status_to_history(status, notes: 'Status updated')
  end

  # Get latest status entry
  def latest_status_entry
    status_history_array.last
  end

  # Get status at a specific time
  def status_at(time)
    entry = status_history_array.find { |e| Time.parse(e['timestamp']) <= time }
    entry&.dig('status')
  end
end

