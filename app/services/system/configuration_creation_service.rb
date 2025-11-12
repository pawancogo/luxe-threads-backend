# frozen_string_literal: true

# Service for creating system configurations
module System
  class ConfigurationCreationService < BaseService
    attr_reader :system_configuration

    def initialize(system_configuration_params, created_by)
      super()
      @system_configuration_params = system_configuration_params
      @created_by = created_by
    end

    def call
      with_transaction do
        create_system_configuration
      end
      set_result(@system_configuration)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def create_system_configuration
      @system_configuration = SystemConfiguration.new(@system_configuration_params)
      @system_configuration.created_by = @created_by
      
      unless @system_configuration.save
        add_errors(@system_configuration.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @system_configuration
      end
    end
  end
end

