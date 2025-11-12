# frozen_string_literal: true

# Service for clearing user search history
module Users
  class SearchHistoryClearService < BaseService
    attr_reader :user

    def initialize(user)
      super()
      @user = user
    end

    def call
      validate_user!
      clear_search_history
      set_result({ message: 'All search history cleared' })
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate_user!
      unless @user.is_a?(User)
        add_error('Invalid user')
        raise StandardError, 'User must be a User instance'
      end
    end

    def clear_search_history
      @user.user_searches.destroy_all
    end
  end
end

