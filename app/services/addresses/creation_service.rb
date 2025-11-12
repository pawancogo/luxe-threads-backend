# frozen_string_literal: true

# Service for creating addresses
module Addresses
  class CreationService < BaseService
    attr_reader :address

    def initialize(user, address_params)
      super()
      @user = user
      @address_params = address_params
    end

    def call
      with_transaction do
        create_address
      end
      set_result(@address)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def create_address
      @address = @user.addresses.build(@address_params)
      
      unless @address.save
        add_errors(@address.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @address
      end
    end
  end
end

