# frozen_string_literal: true

# Service for looking up settings by key
# Extracts lookup logic from controllers
class SettingLookupService < BaseService
  attr_reader :setting

  def initialize(key)
    super()
    @key = key
  end

  def call
    find_setting
    set_result(@setting)
    self
  rescue StandardError => e
    handle_error(e)
    self
  end

  private

  def find_setting
    @setting = Setting.find_by(key: @key)
    
    unless @setting
      add_error('Setting not found')
    end
  end
end

