# frozen_string_literal: true

class Api::V1::NotificationPreferencesController < ApplicationController
  # GET /api/v1/notification_preferences
  def show
    @preferences = current_user.notification_preference || current_user.build_notification_preference
    @preferences.save! if @preferences.new_record?
    
    render_success(format_preferences_data(@preferences), 'Notification preferences retrieved successfully')
  end
  
  # PATCH /api/v1/notification_preferences
  def update
    @preferences = current_user.notification_preference || current_user.build_notification_preference
    
    preferences_params = params[:preferences] || {}
    
    # Update preferences
    if preferences_params[:email].present?
      preferences_params[:email].each do |key, value|
        @preferences.set_preference('email', key, value)
      end
    end
    
    if preferences_params[:sms].present?
      preferences_params[:sms].each do |key, value|
        @preferences.set_preference('sms', key, value)
      end
    end
    
    if preferences_params[:push].present?
      preferences_params[:push].each do |key, value|
        @preferences.set_preference('push', key, value)
      end
    end
    
    if @preferences.save
      render_success(format_preferences_data(@preferences), 'Notification preferences updated successfully')
    else
      render_validation_errors(@preferences.errors.full_messages, 'Failed to update preferences')
    end
  end
  
  private
  
  def format_preferences_data(preferences)
    {
      preferences: preferences.preferences_hash,
      created_at: preferences.created_at,
      updated_at: preferences.updated_at
    }
  end
end

