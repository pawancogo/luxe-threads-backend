# frozen_string_literal: true

# Service for updating email templates
module EmailTemplates
  class UpdateService < BaseService
    attr_reader :email_template

    def initialize(email_template, email_template_params)
      super()
      @email_template = email_template
      @email_template_params = email_template_params
    end

    def call
      with_transaction do
        update_email_template
      end
      set_result(@email_template)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def update_email_template
      unless @email_template.update(@email_template_params)
        add_errors(@email_template.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @email_template
      end
    end
  end
end

