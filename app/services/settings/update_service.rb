# frozen_string_literal: true

# Service for updating settings
module Settings
  class UpdateService < BaseService
    attr_reader :setting

    def initialize(setting, setting_params)
      super()
      @setting = setting
      @setting_params = setting_params
    end

    def call
      with_transaction do
        update_setting
      end
      set_result(@setting)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def update_setting
      unless @setting.update(@setting_params)
        add_errors(@setting.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @setting
      end
    end
  end
end

