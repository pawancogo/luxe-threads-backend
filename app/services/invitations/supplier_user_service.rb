# frozen_string_literal: true

# Service for inviting users to supplier accounts
module Invitations
  class SupplierUserService < BaseService
    attr_reader :supplier_account_user, :user

    def initialize(supplier_profile, email, role, invited_by, invitation_role: 'supplier', permissions: {})
      super()
      @supplier_profile = supplier_profile
      @email = email
      @role = role || 'staff'
      @invited_by = invited_by
      @invitation_role = invitation_role
      @permissions = permissions
    end

    def call
      validate_email!
      check_existing_user!
      find_or_create_user
      create_supplier_account_user
      send_invitation
      set_result(@supplier_account_user)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate_email!
      unless @email.present?
        add_error('Email is required')
        raise StandardError, 'Email is required'
      end
    end

    def check_existing_user!
      existing_user = User.joins(:supplier_account_users)
                         .where(supplier_account_users: { supplier_profile_id: @supplier_profile.id })
                         .find_by(email: @email)
      
      if existing_user
        add_error('User is already part of this supplier account')
        raise StandardError, 'User already exists in supplier account'
      end
    end

    def find_or_create_user
      @user = User.find_or_initialize_by(email: @email)
      @user.role = 'supplier' if @user.new_record?
      @user.save!(validate: false) if @user.new_record?
    end

    def create_supplier_account_user
      @supplier_account_user = SupplierAccountUser.new(
        supplier_profile: @supplier_profile,
        user: @user,
        role: @role,
        status: 'pending_invitation',
        invited_by: @invited_by,
        can_manage_products: @permissions[:can_manage_products] || false,
        can_manage_orders: @permissions[:can_manage_orders] || false,
        can_view_financials: @permissions[:can_view_financials] || false,
        can_manage_users: @permissions[:can_manage_users] || false,
        can_manage_settings: @permissions[:can_manage_settings] || false,
        can_view_analytics: @permissions[:can_view_analytics] || false
      )
      
      unless @supplier_account_user.save
        add_errors(@supplier_account_user.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @supplier_account_user
      end
    end

    def send_invitation
      service = Invitations::Service.new(@user, @invited_by)
      
      unless service.send_supplier_invitation(@invitation_role)
        add_errors(service.errors)
        raise StandardError, 'Failed to send invitation'
      end
    end
  end
end

