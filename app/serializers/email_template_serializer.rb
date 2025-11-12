# frozen_string_literal: true

# Serializer for EmailTemplate API responses
class EmailTemplateSerializer < BaseSerializer
  attributes :id, :template_type, :subject, :body_html, :body_text,
             :from_email, :from_name, :is_active, :variables, :description,
             :created_at, :updated_at

  def variables
    object.variables || {}
  end

  def created_at
    format_date(object.created_at)
  end

  def updated_at
    format_date(object.updated_at)
  end
end

