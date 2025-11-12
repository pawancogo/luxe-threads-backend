# frozen_string_literal: true

# Service for creating supplier profiles (API)
module Suppliers
  class ProfileCreationService < BaseService
    attr_reader :profile

    def initialize(user, profile_params)
      super()
      @user = user
      @profile_params = profile_params
    end

    def call
      validate_user!
      create_profile
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

    def create_profile
      @profile = @user.build_supplier_profile(@profile_params)
      
      unless @profile.save
        add_errors(@profile.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @profile
      end
    end
  end
end

