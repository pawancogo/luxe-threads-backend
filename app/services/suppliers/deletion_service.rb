# frozen_string_literal: true

# Service for deleting suppliers
module Suppliers
  class DeletionService < BaseService
    attr_reader :supplier

    def initialize(supplier)
      super()
      @supplier = supplier
    end

    def call
      with_transaction do
        delete_supplier
      end
      set_result(@supplier)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def delete_supplier
      @supplier.destroy
    end
  end
end

