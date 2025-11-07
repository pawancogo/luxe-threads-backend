# frozen_string_literal: true

module SupplierAuthorization
  extend ActiveSupport::Concern
  include JwtAuthentication
  
  included do
    before_action :authenticate_supplier_request, if: :supplier_route?
    before_action :authorize_supplier!, if: :supplier_route?
  end
  
  private
  
  def supplier_route?
    request.path.start_with?('/api/v1/supplier') || 
    request.path.start_with?('/api/v1/products') ||
    request.path.start_with?('/api/v1/supplier/orders') ||
    request.path.start_with?('/api/v1/supplier/returns')
  end
  
  def authenticate_supplier_request
    token = extract_token
    return unless validate_token_presence(token)
    
    @decoded = decode_token(token)
    return unless @decoded
    
    unless valid_user_token?(@decoded)
      render_unauthorized('Invalid authentication token type')
      return
    end
    
    load_and_validate_supplier(@decoded[:user_id])
  rescue StandardError => e
    handle_auth_error(e)
  end
  
  def valid_user_token?(decoded)
    decoded[:type] == 'user' && decoded[:user_id].present?
  end
  
  def load_and_validate_supplier(user_id)
    @current_user = User.find(user_id)
    
    unless @current_user.is_active && @current_user.deleted_at.nil?
      render_unauthorized('User account is inactive')
      return false
    end
    
    supplier_profile = find_supplier_profile
    return false unless supplier_profile
    
    @current_supplier_account_user = find_supplier_account_user(supplier_profile)
    return false unless @current_supplier_account_user
    
    unless supplier_profile.is_active && !supplier_profile.is_suspended
      render_unauthorized('Supplier account is inactive or suspended')
      return false
    end
    
    true
  end
  
  def find_supplier_profile
    profile = @current_user.primary_supplier_profile || @current_user.supplier_profile
    unless profile
      render_unauthorized('Supplier profile not found')
      return nil
    end
    profile
  end
  
  def find_supplier_account_user(supplier_profile)
    account_user = SupplierAccountUser
      .where(supplier_profile: supplier_profile, user: @current_user)
      .active
      .first
    
    unless account_user
      render_unauthorized('Supplier account access not found')
      return nil
    end
    
    account_user
  end
  
  def authorize_supplier!
    unless @current_supplier_account_user
      render_unauthorized('Supplier access required')
      return
    end
    true
  end
  
  def require_supplier_permission!(permission)
    unless @current_supplier_account_user&.has_permission?(permission)
      render_unauthorized("Permission required: #{permission}")
      return
    end
  end
  
  def require_supplier_role!(roles)
    roles = [roles] unless roles.is_a?(Array)
    
    # Check RBAC roles
    has_rbac_role = roles.any? { |role| @current_supplier_account_user&.has_role?(role) }
    
    # Fallback to legacy role check
    has_legacy_role = roles.include?(@current_supplier_account_user&.role&.to_s)
    
    unless has_rbac_role || has_legacy_role
      render_unauthorized('Insufficient privileges for this action')
      return
    end
  end
  
  # Scope products to current supplier
  def scope_supplier_products
    return Product.none unless @current_supplier_account_user
    
    supplier_profile = @current_supplier_account_user.supplier_profile
    Product.where(supplier_profile_id: supplier_profile.id)
  end
  
  # Scope orders to current supplier
  def scope_supplier_orders
    return Order.none unless @current_supplier_account_user
    
    supplier_profile = @current_supplier_account_user.supplier_profile
    Order.joins(order_items: :product)
      .where(products: { supplier_profile_id: supplier_profile.id })
      .distinct
  end
  
  # Scope analytics to current supplier
  def supplier_analytics_scope
    return {} unless @current_supplier_account_user
    
    supplier_profile = @current_supplier_account_user.supplier_profile
    {
      supplier_profile_id: supplier_profile.id,
      products: scope_supplier_products,
      orders: scope_supplier_orders
    }
  end
  
  # Check if supplier can access a specific resource
  def supplier_can_access_resource?(resource)
    return false unless @current_supplier_account_user && resource
    
    # Check if resource belongs to supplier
    if resource.respond_to?(:supplier_profile_id)
      return resource.supplier_profile_id == @current_supplier_account_user.supplier_profile_id
    end
    
    # Check if resource is a product variant
    if resource.respond_to?(:product)
      return resource.product.supplier_profile_id == @current_supplier_account_user.supplier_profile_id
    end
    
    false
  end
  
  attr_reader :current_supplier_account_user
  attr_reader :current_user
end

