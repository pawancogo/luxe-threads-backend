# frozen_string_literal: true

# Service for updating addresses
module Addresses
  class UpdateService < BaseService
    attr_reader :address

    def initialize(address, address_params)
      super()
      @address = address
      @address_params = address_params
    end

    def call
      with_transaction do
        update_address
      end
      set_result(@address)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def update_address
      unless @address.update(@address_params)
        add_errors(@address.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @address
      end
    end
  end
end

