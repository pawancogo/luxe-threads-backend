# frozen_string_literal: true

# Service for updating user general information (non-password fields)
module Users
  class GeneralUpdateService < BaseService
    attr_reader :user

    def initialize(user, user_params)
      super()
      @user = user
      @user_params = user_params.except(:password, :password_confirmation, :current_password)
    end

    def call
      with_transaction do
        update_user
      end
      set_result(@user)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def update_user
      unless @user.update(@user_params)
        add_errors(@user.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @user
      end
    end
  end
end

