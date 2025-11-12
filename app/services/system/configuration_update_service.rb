# frozen_string_literal: true

# Service for updating system configurations
module System
  class ConfigurationUpdateService < BaseService
    attr_reader :system_configuration

    def initialize(system_configuration, system_configuration_params)
      super()
      @system_configuration = system_configuration
      @system_configuration_params = system_configuration_params
    end

    def call
      with_transaction do
        update_system_configuration
      end
      set_result(@system_configuration)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def update_system_configuration
      unless @system_configuration.update(@system_configuration_params)
        add_errors(@system_configuration.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @system_configuration
      end
    end
  end
end

