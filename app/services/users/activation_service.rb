# frozen_string_literal: true

# Service for activating users
module Users
  class ActivationService < BaseService
    attr_reader :user

    def initialize(user)
      super()
      @user = user
    end

    def call
      with_transaction do
        activate_user
      end
      set_result(@user)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def activate_user
      unless @user.update(is_active: true, deleted_at: nil)
        add_errors(@user.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @user
      end
    end
  end
end

