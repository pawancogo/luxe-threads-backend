# frozen_string_literal: true

# Service for creating notification preferences
module Notifications
  class PreferenceCreationService < BaseService
    attr_reader :preferences

    def initialize(user)
      super()
      @user = user
    end

    def call
      with_transaction do
        create_preferences
      end
      set_result(@preferences)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def create_preferences
      @preferences = @user.notification_preference || @user.build_notification_preference
      
      if @preferences.new_record?
        unless @preferences.save
          add_errors(@preferences.errors.full_messages)
          raise ActiveRecord::RecordInvalid, @preferences
        end
      end
    end
  end
end

