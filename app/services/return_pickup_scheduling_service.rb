# frozen_string_literal: true

# Service for scheduling return pickups
class ReturnPickupSchedulingService < BaseService
  attr_reader :return_request

  def initialize(return_request, scheduled_at)
    super()
    @return_request = return_request
    @scheduled_at = scheduled_at
  end

  def call
    validate_scheduled_at!
    schedule_pickup
    update_status_history
    set_result(@return_request)
    self
  rescue StandardError => e
    handle_error(e)
    self
  end

  private

  def validate_scheduled_at!
    if @scheduled_at.blank?
      add_error('Pickup scheduled_at is required')
      raise StandardError, 'Scheduled time required'
    end
  end

  def schedule_pickup
    unless @return_request.update(
      pickup_scheduled_at: @scheduled_at,
      status: 'pickup_scheduled'
    )
      add_errors(@return_request.errors.full_messages)
      raise ActiveRecord::RecordInvalid, @return_request
    end
  end

  def update_status_history
    @return_request.update_status_history('pickup_scheduled', 'Pickup scheduled')
  end
end


