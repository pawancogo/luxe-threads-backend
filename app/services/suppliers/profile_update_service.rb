# frozen_string_literal: true

# Service for updating supplier profiles (API)
module Suppliers
  class ProfileUpdateService < BaseService
    attr_reader :profile

    def initialize(user, profile_params)
      super()
      @user = user
      @profile_params = profile_params
    end

    def call
      validate_user!
      find_or_create_profile
      update_profile
      set_result(@profile)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate_user!
      unless @user.supplier?
        add_error('User must be a supplier')
        raise StandardError, 'User must be a supplier'
      end
    end

    def find_or_create_profile
      @profile = @user.supplier_profile
      
      unless @profile
        add_error('Supplier profile not found. Please create a supplier profile first.')
        raise StandardError, 'Supplier profile not found'
      end
    end

    def update_profile
      unless @profile.update(@profile_params)
        add_errors(@profile.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @profile
      end
    end
  end
end

