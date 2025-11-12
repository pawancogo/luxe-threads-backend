# frozen_string_literal: true

# Service for updating notification preferences
module Notifications
  class PreferencesUpdateService < BaseService
    attr_reader :preferences

    def initialize(user, preferences_params)
      super()
      @user = user
      @preferences_params = preferences_params
    end

    def call
      find_or_create_preferences
      update_preferences
      set_result(@preferences)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def find_or_create_preferences
      @preferences = @user.notification_preference || @user.build_notification_preference
      @preferences.save! if @preferences.new_record?
    end

    def update_preferences
      if @preferences_params[:email].present?
        @preferences_params[:email].each do |key, value|
          @preferences.set_preference('email', key, value)
        end
      end

      if @preferences_params[:sms].present?
        @preferences_params[:sms].each do |key, value|
          @preferences.set_preference('sms', key, value)
        end
      end

      if @preferences_params[:push].present?
        @preferences_params[:push].each do |key, value|
          @preferences.set_preference('push', key, value)
        end
      end

      unless @preferences.save
        add_errors(@preferences.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @preferences
      end
    end
  end
end

