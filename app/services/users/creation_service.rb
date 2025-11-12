# frozen_string_literal: true

# Service for creating users
# Follows Single Responsibility - only creates the user, delegates resource creation
module Users
  class CreationService < BaseService
    attr_reader :user

    def initialize(user_params, resource_service: nil)
      super()
      @user_params = user_params
      @resource_service = resource_service || UserResourceCreationService
    end

    def call
      with_transaction do
        create_user
        create_resources if @user.persisted?
        set_result(@user)
      end

      self
    rescue ActiveRecord::RecordInvalid => e
      handle_record_invalid(e)
      @user ||= e.record
      self
    rescue ActiveRecord::RecordNotUnique => e
      # Re-raise constraint errors for controller to handle with user-friendly messages
      set_last_error(e)
      raise
    rescue StandardError => e
      # Re-raise constraint errors
      if constraint_error?(e)
        set_last_error(e)
        raise
      end
      handle_error(e)
      @user ||= build_user
      self
    end

    # Alias for backward compatibility
    def result
      @user || super
    end

    private

    def create_user
      log_execution('create_user', email: @user_params[:email])

      @user = User.new(@user_params)
      unless @user.save
        add_errors(@user.errors.full_messages.uniq)
        raise ActiveRecord::RecordInvalid, @user
      end
    end

    def create_resources
      service = @resource_service.new(@user, extract_supplier_options)
      service.call

      unless service.success?
        add_errors(service.errors)
        set_last_error(service.last_error) if service.last_error
      end
    end

    def extract_supplier_options
      return {} unless supplier_user?

      {
        company_name: @user_params[:company_name],
        gst_number: @user_params[:gst_number],
        description: @user_params[:description]
      }.compact
    end

    def build_user
      User.new(@user_params)
    end

    def supplier_user?
      @user_params[:role] == 'supplier' || @user&.role == 'supplier'
    end

    def constraint_error?(error)
      message = error.message.to_s.downcase
      message.include?('unique constraint') || message.include?('constraint')
    end
  end
end

