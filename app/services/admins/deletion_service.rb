# frozen_string_literal: true

# Service for deleting admins
module Admins
  class DeletionService < BaseService
    attr_reader :admin

    def initialize(admin)
      super()
      @admin = admin
    end

    def call
      with_transaction do
        delete_admin
      end
      set_result(@admin)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def delete_admin
      @admin.destroy
    end
  end
end

