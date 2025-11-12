# frozen_string_literal: true

# Service for updating admins
module Admins
  class UpdateService < BaseService
    attr_reader :admin

    def initialize(admin, admin_params)
      super()
      @admin = admin
      @admin_params = admin_params
    end

    def call
      with_transaction do
        update_admin
      end
      set_result(@admin)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def update_admin
      unless @admin.update(@admin_params)
        add_errors(@admin.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @admin
      end
    end
  end
end

