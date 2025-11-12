# frozen_string_literal: true

# Service for creating settings
module Settings
  class CreationService < BaseService
    attr_reader :setting

    def initialize(setting_params)
      super()
      @setting_params = setting_params
    end

    def call
      with_transaction do
        create_setting
      end
      set_result(@setting)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def create_setting
      @setting = Setting.new(@setting_params)
      
      unless @setting.save
        add_errors(@setting.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @setting
      end
    end
  end
end

