# frozen_string_literal: true

class Setting < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  validates :value_type, inclusion: { in: %w[string integer float boolean json] }
  validates :category, inclusion: { in: %w[general payment shipping email feature_flags] }

  before_save :normalize_value

  scope :by_category, ->(category) { where(category: category) }
  scope :public_settings, -> { where(is_public: true) }

  def self.get(key, default = nil)
    setting = find_by(key: key)
    return default unless setting
    setting.cast_value
  end

  def self.set(key, value, value_type: 'string', category: 'general')
    setting = find_or_initialize_by(key: key)
    setting.value = value.to_s
    setting.value_type = value_type
    setting.category = category
    setting.save
    setting
  end

  def cast_value
    case value_type
    when 'integer'
      value.to_i
    when 'float'
      value.to_f
    when 'boolean'
      value.to_s.downcase.in?(%w[true 1 yes])
    when 'json'
      JSON.parse(value) rescue value
    else
      value
    end
  end

  private

  def normalize_value
    self.value = case value_type
    when 'integer'
      value.to_i.to_s
    when 'float'
      value.to_f.to_s
    when 'boolean'
      value.to_s.downcase.in?(%w[true 1 yes]) ? 'true' : 'false'
    when 'json'
      value.is_a?(String) ? value : value.to_json
    else
      value.to_s
    end
  end
end

