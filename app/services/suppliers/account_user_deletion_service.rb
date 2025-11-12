# frozen_string_literal: true

# Service for removing a user from a supplier account
module Suppliers
  class AccountUserDeletionService < BaseService
    attr_reader :account_user

    def initialize(account_user)
      super()
      @account_user = account_user
    end

    def call
      validate_removal!
      with_transaction do
        remove_user
      end
      set_result(@account_user)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate_removal!
      if @account_user.owner?
        add_error('Cannot remove owner')
        raise StandardError, 'The owner cannot be removed from the supplier account'
      end
    end

    def remove_user
      @account_user.destroy
    end
  end
end

