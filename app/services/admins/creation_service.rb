# frozen_string_literal: true

# Service for creating admins
module Admins
  class CreationService < BaseService
    attr_reader :admin

    def initialize(admin_params)
      super()
      @admin_params = admin_params
    end

    def call
      with_transaction do
        create_admin
        send_verification_email unless @admin.super_admin?
      end
      set_result(@admin)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def create_admin
      @admin = Admin.new(@admin_params)
      
      unless @admin.save
        add_errors(@admin.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @admin
      end
    end

    def send_verification_email
      Authentication::EmailVerificationService.new(@admin).send_verification_email
    end
  end
end

