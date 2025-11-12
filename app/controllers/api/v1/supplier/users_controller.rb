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
        SupplierUserSerializer.new(
          account_user.user,
          supplier_profile: @supplier_profile
        ).as_json
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
      
      render_success(
        SupplierUserSerializer.new(@user, supplier_profile: @supplier_profile).as_json,
        'Supplier user retrieved successfully'
      )
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
      
      permissions = {
        can_manage_products: user_params[:can_manage_products] || false,
        can_manage_orders: user_params[:can_manage_orders] || false,
        can_view_financials: user_params[:can_view_financials] || false,
        can_manage_users: user_params[:can_manage_users] || false,
        can_manage_settings: user_params[:can_manage_settings] || false,
        can_view_analytics: user_params[:can_view_analytics] || false
      }
      
      service = Invitations::SupplierUserService.new(
        @supplier_profile,
        email,
        role,
        @current_user,
        invitation_role: invitation_role,
        permissions: permissions
      )
      service.call
      
      if service.success?
        user_data = {
          id: service.user.id,
          email: service.user.email,
          role: role,
          invitation_status: service.user.invitation_status,
          invited_at: service.supplier_account_user.created_at
        }
        
        render_created(user_data, "Invitation sent to #{service.user.email} successfully")
      else
        render_validation_errors(service.errors, 'Failed to send invitation')
      end
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
      
      service = Invitations::Service.new(@user, @current_user)
      
      if service.resend_invitation
        render_success(
          SupplierUserSerializer.new(@user, supplier_profile: @supplier_profile).as_json,
          "Invitation resent to #{@user.email}"
        )
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
      
      service = Suppliers::AccountUserUpdateService.new(account_user, update_params)
      service.call
      
      if service.success?
        render_success(
          SupplierUserSerializer.new(@user.reload, supplier_profile: @supplier_profile).as_json,
          'User updated successfully'
        )
      else
        render_validation_errors(service.errors, 'Failed to update user')
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
      
      service = Suppliers::AccountUserDeletionService.new(account_user)
      service.call
      
      if service.success?
        render_success({}, 'User removed from supplier account successfully')
      else
        render_validation_errors(service.errors, 'Failed to remove user')
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
    
  end
end

