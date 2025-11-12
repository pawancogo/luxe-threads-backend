# frozen_string_literal: true

# Service for marking all notifications as read
module Notifications
  class MarkAllReadService < BaseService
    attr_reader :user, :count

    def initialize(user)
      super()
      @user = user
    end

    def call
      mark_all_read
      set_result({ count: @count })
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def mark_all_read
      @user.notifications.unread.update_all(is_read: true, read_at: Time.current)
      @count = @user.notifications.unread.count
    end
  end
end

