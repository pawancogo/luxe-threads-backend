# frozen_string_literal: true

# Controller for suppliers to manage their team members (invite other suppliers)
module Api::V1::Supplier
  class UsersController < ApplicationController
    include SupplierAuthorization
    
    before_action :authenticate_supplier_request
    before_action :authorize_supplier!
    before_action :set_supplier_profile
    before_action :set_user, only: [:show, :update, :destroy, :resend_invitation]
    
    # GET /api/v1/supplier/users
    # List all users in the supplier account
    def index
      @users = @current_user.primary_supplier_profile&.supplier_account_users&.includes(:user) || []
      
      users_data = @users.map do |account_user|
        user = account_user.user
        {
          id: user.id,
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name,
          full_name: user.full_name,
          role: account_user.role,
          status: account_user.status,
          can_manage_products: account_user.can_manage_products,
          can_manage_orders: account_user.can_manage_orders,
          can_view_financials: account_user.can_view_financials,
          can_manage_users: account_user.can_manage_users,
          can_manage_settings: account_user.can_manage_settings,
          can_view_analytics: account_user.can_view_analytics,
          invited_at: account_user.created_at,
          accepted_at: account_user.accepted_at,
          invitation_status: user.invitation_status
        }
      end
      
      render_success(users_data, 'Supplier users retrieved successfully')
    end
    
    # GET /api/v1/supplier/users/:id
    def show
      account_user = @user.supplier_account_users.find_by(supplier_profile: @supplier_profile)
      
      unless account_user
        render_not_found('User not found in this supplier account')
        return
      end
      
      user_data = {
        id: @user.id,
        email: @user.email,
        first_name: @user.first_name,
        last_name: @user.last_name,
        full_name: @user.full_name,
        phone_number: @user.phone_number,
        role: account_user.role,
        status: account_user.status,
        permissions: {
          can_manage_products: account_user.can_manage_products,
          can_manage_orders: account_user.can_manage_orders,
          can_view_financials: account_user.can_view_financials,
          can_manage_users: account_user.can_manage_users,
          can_manage_settings: account_user.can_manage_settings,
          can_view_analytics: account_user.can_view_analytics
        },
        invited_at: account_user.created_at,
        accepted_at: account_user.accepted_at,
        invitation_status: @user.invitation_status
      }
      
      render_success(user_data, 'Supplier user retrieved successfully')
    end
    
    # POST /api/v1/supplier/users/invite
    # Invite a new user to the supplier account
    # Only parent supplier (owner) or admin can invite child suppliers
    def invite
      unless can_invite_users?
        render_unauthorized('Only the parent supplier (owner) or admin can invite users to this account')
        return
      end
      
      user_params = params[:user] || {}
      email = user_params[:email]
      role = user_params[:role] || 'staff'
      invitation_role = user_params[:invitation_role] || 'supplier'
      
      unless email.present?
        render_validation_errors(['Email is required'], 'Invitation failed')
        return
      end
      
      # Check if user already exists in this supplier account
      existing_user = User.joins(:supplier_account_users)
                         .where(supplier_account_users: { supplier_profile_id: @supplier_profile.id })
                         .find_by(email: email)
      
      if existing_user
        render_validation_errors(['User is already part of this supplier account'], 'Invitation failed')
        return
      end
      
      # Create or find user
      @user = User.find_or_initialize_by(email: email)
      @user.role = 'supplier' if @user.new_record?
      
      # Use SupplierAccountUser's invitation system if available, otherwise use InvitationService
      ActiveRecord::Base.transaction do
        # Create SupplierAccountUser record with pending invitation
        supplier_account_user = SupplierAccountUser.new(
          supplier_profile: @supplier_profile,
          user: @user,
          role: role,
          status: 'pending_invitation',
          invited_by: @current_user,
          can_manage_products: user_params[:can_manage_products] || false,
          can_manage_orders: user_params[:can_manage_orders] || false,
          can_view_financials: user_params[:can_view_financials] || false,
          can_manage_users: user_params[:can_manage_users] || false,
          can_manage_settings: user_params[:can_manage_settings] || false,
          can_view_analytics: user_params[:can_view_analytics] || false
        )
        
        # Save user first if new
        @user.save!(validate: false) if @user.new_record?
        
        # Use InvitationService to send invitation email
        service = InvitationService.new(@user, @current_user)
        
        if service.send_supplier_invitation(invitation_role)
          # Save supplier account user
          supplier_account_user.save!
          
          user_data = {
            id: @user.id,
            email: @user.email,
            role: role,
            invitation_status: @user.invitation_status,
            invited_at: supplier_account_user.created_at
          }
          
          render_created(user_data, "Invitation sent to #{@user.email} successfully")
        else
          raise ActiveRecord::RecordInvalid.new(@user)
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      render_validation_errors(service&.errors || @user.errors.full_messages, 'Failed to send invitation')
    rescue StandardError => e
      Rails.logger.error "Supplier user invitation failed: #{e.message}"
      render_validation_errors(["An error occurred: #{e.message}"], 'Failed to send invitation')
    end
    
    # POST /api/v1/supplier/users/:id/resend_invitation
    def resend_invitation
      unless can_invite_users?
        render_unauthorized('Only the parent supplier (owner) or admin can resend invitations')
        return
      end
      
      account_user = @user.supplier_account_users.find_by(supplier_profile: @supplier_profile)
      
      unless account_user
        render_not_found('User not found in this supplier account')
        return
      end
      
      service = InvitationService.new(@user, @current_user)
      
      if service.resend_invitation
        render_success(format_user_data(@user), "Invitation resent to #{@user.email}")
      else
        render_validation_errors(service.errors, 'Failed to resend invitation')
      end
    end
    
    # PATCH /api/v1/supplier/users/:id
    def update
      unless can_manage_users?
        render_unauthorized('You do not have permission to update users')
        return
      end
      
      account_user = @user.supplier_account_users.find_by(supplier_profile: @supplier_profile)
      
      unless account_user
        render_not_found('User not found in this supplier account')
        return
      end
      
      update_params = params[:user] || {}
      
      # Update account user permissions
      if account_user.update(
        role: update_params[:role] || account_user.role,
        can_manage_products: update_params[:can_manage_products] != nil ? update_params[:can_manage_products] : account_user.can_manage_products,
        can_manage_orders: update_params[:can_manage_orders] != nil ? update_params[:can_manage_orders] : account_user.can_manage_orders,
        can_view_financials: update_params[:can_view_financials] != nil ? update_params[:can_view_financials] : account_user.can_view_financials,
        can_manage_users: update_params[:can_manage_users] != nil ? update_params[:can_manage_users] : account_user.can_manage_users,
        can_manage_settings: update_params[:can_manage_settings] != nil ? update_params[:can_manage_settings] : account_user.can_manage_settings,
        can_view_analytics: update_params[:can_view_analytics] != nil ? update_params[:can_view_analytics] : account_user.can_view_analytics
      )
        render_success(format_user_data(@user), 'User updated successfully')
      else
        render_validation_errors(account_user.errors.full_messages, 'Failed to update user')
      end
    end
    
    # DELETE /api/v1/supplier/users/:id
    def destroy
      unless can_manage_users?
        render_unauthorized('You do not have permission to remove users')
        return
      end
      
      account_user = @user.supplier_account_users.find_by(supplier_profile: @supplier_profile)
      
      unless account_user
        render_not_found('User not found in this supplier account')
        return
      end
      
      # Prevent removing the owner
      if account_user.owner?
        render_error('Cannot remove owner', 'The owner cannot be removed from the supplier account')
        return
      end
      
      if account_user.destroy
        render_success({}, 'User removed from supplier account successfully')
      else
        render_validation_errors(account_user.errors.full_messages, 'Failed to remove user')
      end
    end
    
    private
    
    def set_supplier_profile
      @supplier_profile = @current_user.primary_supplier_profile || @current_user.supplier_profile
      
      unless @supplier_profile
        render_unauthorized('Supplier profile not found')
        return false
      end
    end
    
    def set_user
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_not_found('User not found')
    end
    
    def can_manage_users?
      @current_supplier_account_user&.can_manage_users? || @current_supplier_account_user&.owner?
    end
    
    # Only parent supplier (owner) or admin can invite users
    # Child suppliers (even with can_manage_users permission) cannot invite
    def can_invite_users?
      return false unless @current_supplier_account_user
      
      # Only owner (parent supplier) can invite
      @current_supplier_account_user.owner?
    end
    
    def format_user_data(user)
      account_user = user.supplier_account_users.find_by(supplier_profile: @supplier_profile)
      
      {
        id: user.id,
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name,
        full_name: user.full_name,
        phone_number: user.phone_number,
        role: account_user&.role,
        status: account_user&.status,
        permissions: {
          can_manage_products: account_user&.can_manage_products,
          can_manage_orders: account_user&.can_manage_orders,
          can_view_financials: account_user&.can_view_financials,
          can_manage_users: account_user&.can_manage_users,
          can_manage_settings: account_user&.can_manage_settings,
          can_view_analytics: account_user&.can_view_analytics
        },
        invitation_status: user.invitation_status
      }
    end
  end
end

