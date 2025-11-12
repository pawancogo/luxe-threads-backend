# frozen_string_literal: true

# Service for generating email template previews
class EmailTemplatePreviewService < BaseService
  attr_reader :preview_data

  def initialize(email_template, preview_variables)
    super()
    @email_template = email_template
    @preview_variables = preview_variables || {}
  end

  def call
    generate_preview
    set_result(@preview_data)
    self
  rescue StandardError => e
    handle_error(e)
    self
  end

  private

  def generate_preview
    @preview_data = {
      subject: @email_template.interpolate(@email_template.subject, @preview_variables),
      body_html: @email_template.body_html ? @email_template.interpolate(@email_template.body_html, @preview_variables) : nil,
      body_text: @email_template.body_text ? @email_template.interpolate(@email_template.body_text, @preview_variables) : nil,
      from_email: @email_template.from_email,
      from_name: @email_template.from_name
    }
  end
end

