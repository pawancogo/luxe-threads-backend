# frozen_string_literal: true

class Api::V1::NotificationPreferencesController < ApplicationController
  # GET /api/v1/notification_preferences
  def show
    service = Notifications::PreferenceCreationService.new(current_user)
    service.call
    
    if service.success?
      render_success(
        NotificationPreferenceSerializer.new(service.preferences).as_json,
        'Notification preferences retrieved successfully'
      )
    else
      render_validation_errors(service.errors, 'Failed to retrieve notification preferences')
    end
  end
  
  # PATCH /api/v1/notification_preferences
  def update
    preferences_params = params[:preferences] || {}
    
    service = Notifications::PreferencesUpdateService.new(current_user, preferences_params)
    service.call
    
    if service.success?
      render_success(
        NotificationPreferenceSerializer.new(service.preferences).as_json,
        'Notification preferences updated successfully'
      )
    else
      render_validation_errors(service.errors, 'Failed to update preferences')
    end
  end
end

