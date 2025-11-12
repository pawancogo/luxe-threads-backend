# frozen_string_literal: true

# Serializer for Setting API responses
class SettingSerializer < BaseSerializer
  attributes :id, :key, :value, :value_type, :category, :description,
             :is_public, :created_at, :updated_at

  def value
    object.cast_value
  end

  def created_at
    format_date(object.created_at)
  end

  def updated_at
    format_date(object.updated_at)
  end
end

