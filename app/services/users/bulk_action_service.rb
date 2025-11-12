# frozen_string_literal: true

# Service for bulk user actions
module Users
  class BulkActionService < BaseService
    attr_reader :users

    def initialize(user_ids, action, admin: nil)
      super()
      @user_ids = Array(user_ids).reject(&:blank?)
      @action = action
      @admin = admin
    end

    def call
      validate!
      perform_action
      set_result(@users)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate!
      if @user_ids.empty?
        add_error('Please select at least one user')
        raise StandardError, 'No users selected'
      end

      unless %w[activate deactivate delete].include?(@action)
        add_error('Invalid action')
        raise StandardError, 'Invalid action'
      end
    end

    def perform_action
      @users = User.where(id: @user_ids)
      
      case @action
      when 'activate'
        activate_users
      when 'deactivate'
        deactivate_users
      when 'delete'
        delete_users
      end
    end

    def activate_users
      @users.update_all(is_active: true, deleted_at: nil)
    end

    def deactivate_users
      @users.find_each do |user|
        user.update(is_active: false, deleted_at: Time.current)
        # Send verification email
        unless user.email_verifications.pending.active.exists?
          Authentication::EmailVerificationService.new(user).send_verification_email
        end
      end
    end

    def delete_users
      @users.destroy_all
    end
  end
end

