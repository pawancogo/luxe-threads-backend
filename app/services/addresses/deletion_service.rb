# frozen_string_literal: true

# Service for deleting addresses
module Addresses
  class DeletionService < BaseService
    attr_reader :address

    def initialize(address)
      super()
      @address = address
    end

    def call
      with_transaction do
        delete_address
      end
      set_result(@address)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def delete_address
      @address.destroy
    end
  end
end

