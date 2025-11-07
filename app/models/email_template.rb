# frozen_string_literal: true

class EmailTemplate < ApplicationRecord
  validates :template_type, presence: true, uniqueness: true
  validates :subject, presence: true
  
  # Note: variables is a JSON column, so it doesn't need serialize
  # JSON columns handle serialization natively in Rails

  TEMPLATE_TYPES = %w[
    welcome
    order_confirmation
    order_shipped
    order_delivered
    order_cancelled
    password_reset
    email_verification
    return_approved
    return_rejected
    payment_failed
    payment_success
    supplier_approval
    supplier_rejection
    product_approved
    product_rejected
  ].freeze

  scope :active, -> { where(is_active: true) }

  def self.render(template_type, variables = {})
    template = active.find_by(template_type: template_type)
    return nil unless template
    
    subject = template.interpolate(template.subject, variables)
    body_html = template.body_html ? template.interpolate(template.body_html, variables) : nil
    body_text = template.body_text ? template.interpolate(template.body_text, variables) : nil
    
    {
      subject: subject,
      body_html: body_html,
      body_text: body_text,
      from_email: template.from_email,
      from_name: template.from_name
    }
  end

  def interpolate(text, variables = {})
    return text unless text.present?
    
    result = text.dup
    variables.each do |key, value|
      result.gsub!(/\{\{#{key}\}\}/, value.to_s)
    end
    result
  end
end

