# frozen_string_literal: true

# Service for updating supplier account user permissions and role
module Suppliers
  class AccountUserUpdateService < BaseService
    attr_reader :account_user

    def initialize(account_user, update_params)
      super()
      @account_user = account_user
      @update_params = update_params
    end

    def call
      with_transaction do
        update_account_user
      end
      set_result(@account_user)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def update_account_user
      update_hash = {
        role: @update_params[:role] || @account_user.role,
        can_manage_products: @update_params[:can_manage_products] != nil ? @update_params[:can_manage_products] : @account_user.can_manage_products,
        can_manage_orders: @update_params[:can_manage_orders] != nil ? @update_params[:can_manage_orders] : @account_user.can_manage_orders,
        can_view_financials: @update_params[:can_view_financials] != nil ? @update_params[:can_view_financials] : @account_user.can_view_financials,
        can_manage_users: @update_params[:can_manage_users] != nil ? @update_params[:can_manage_users] : @account_user.can_manage_users,
        can_manage_settings: @update_params[:can_manage_settings] != nil ? @update_params[:can_manage_settings] : @account_user.can_manage_settings,
        can_view_analytics: @update_params[:can_view_analytics] != nil ? @update_params[:can_view_analytics] : @account_user.can_view_analytics
      }
      
      unless @account_user.update(update_hash)
        add_errors(@account_user.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @account_user
      end
    end
  end
end

