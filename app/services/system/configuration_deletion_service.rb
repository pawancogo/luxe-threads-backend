# frozen_string_literal: true

# Service for deleting system configurations
module System
  class ConfigurationDeletionService < BaseService
    attr_reader :system_configuration

    def initialize(system_configuration)
      super()
      @system_configuration = system_configuration
    end

    def call
      with_transaction do
        delete_system_configuration
      end
      set_result(@system_configuration)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def delete_system_configuration
      @system_configuration.destroy
    end
  end
end

