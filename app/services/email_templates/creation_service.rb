# frozen_string_literal: true

# Service for creating email templates
module EmailTemplates
  class CreationService < BaseService
    attr_reader :email_template

    def initialize(email_template_params)
      super()
      @email_template_params = email_template_params
    end

    def call
      with_transaction do
        create_email_template
      end
      set_result(@email_template)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def create_email_template
      @email_template = EmailTemplate.new(@email_template_params)
      
      unless @email_template.save
        add_errors(@email_template.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @email_template
      end
    end
  end
end

