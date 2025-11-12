# frozen_string_literal: true

# Service for deactivating system configurations
module System
  class ConfigurationDeactivationService < BaseService
    attr_reader :system_configuration

    def initialize(system_configuration)
      super()
      @system_configuration = system_configuration
    end

    def call
      with_transaction do
        deactivate_configuration
      end
      set_result(@system_configuration)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def deactivate_configuration
      unless @system_configuration.update(is_active: false)
        add_errors(@system_configuration.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @system_configuration
      end
    end
  end
end

