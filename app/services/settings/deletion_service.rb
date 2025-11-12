# frozen_string_literal: true

# Service for deleting settings
module Settings
  class DeletionService < BaseService
    attr_reader :setting

    def initialize(setting)
      super()
      @setting = setting
    end

    def call
      with_transaction do
        delete_setting
      end
      set_result(@setting)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def delete_setting
      @setting.destroy
    end
  end
end

