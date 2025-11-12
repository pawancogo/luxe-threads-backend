# frozen_string_literal: true

# Service for marking notifications as read
module Notifications
  class MarkReadService < BaseService
    attr_reader :notification

    def initialize(notification)
      super()
      @notification = notification
    end

    def call
      mark_as_read
      set_result(@notification)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def mark_as_read
      @notification.mark_as_read!
    end
  end
end

