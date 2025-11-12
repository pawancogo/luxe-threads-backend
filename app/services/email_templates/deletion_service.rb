# frozen_string_literal: true

# Service for deleting email templates
module EmailTemplates
  class DeletionService < BaseService
    attr_reader :email_template

    def initialize(email_template)
      super()
      @email_template = email_template
    end

    def call
      with_transaction do
        delete_email_template
      end
      set_result(@email_template)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def delete_email_template
      @email_template.destroy
    end
  end
end

