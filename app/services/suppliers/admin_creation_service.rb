# frozen_string_literal: true

# Service for creating suppliers by admin
module Suppliers
  class AdminCreationService < BaseService
    attr_reader :supplier

    def initialize(supplier_params, admin)
      super()
      @supplier_params = supplier_params.dup
      @profile_params = @supplier_params.delete(:supplier_profile_attributes)
      @admin = admin
    end

    def call
      validate!
      create_supplier
      create_profile if @profile_params.present?
      create_account_user if @supplier.supplier_profile.present?
      send_verification_email if @supplier.persisted?
      set_result(@supplier)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate!
      unless @admin
        add_error('Admin is required')
        raise StandardError, 'Admin is required'
      end
    end

    def create_supplier
      @supplier = User.new(@supplier_params.merge(role: 'supplier'))
      
      unless @supplier.save
        add_errors(@supplier.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @supplier
      end
    end

    def create_profile
      profile = @supplier.build_supplier_profile(@profile_params)
      profile.owner_id = @supplier.id
      profile.user_id = @supplier.id
      
      unless profile.save
        add_errors(profile.errors.full_messages)
        raise ActiveRecord::RecordInvalid, profile
      end
    end

    def create_account_user
      SupplierAccountUser.create!(
        supplier_profile: @supplier.supplier_profile,
        user: @supplier,
        role: 'owner',
        status: 'active',
        can_manage_products: true,
        can_manage_orders: true,
        can_view_financials: true,
        can_manage_users: true,
        can_manage_settings: true,
        can_view_analytics: true,
        accepted_at: Time.current
      )
    end

    def send_verification_email
      return if @supplier.email_verified?
      
      Authentication::EmailVerificationService.new(@supplier).send_verification_email
    rescue StandardError => e
      # Log but don't fail the service if email sending fails
      Rails.logger.warn "Failed to send verification email to #{@supplier.email}: #{e.message}"
    end
  end
end

