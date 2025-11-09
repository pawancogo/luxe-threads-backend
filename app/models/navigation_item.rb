# frozen_string_literal: true

require 'set'

# Navigation Item Model
# Stores navigation configuration in database for dynamic management
class NavigationItem < ApplicationRecord
  # Validations
  validates :key, presence: true, uniqueness: true, format: { with: /\A[a-z0-9_]+\z/ }
  validates :label, presence: true
  validates :path_method, presence: true
  validates :display_order, presence: true
  
  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :visible, -> { active.where(always_visible: false) }
  scope :by_section, ->(section) { where(section: section) }
  scope :ordered, -> { order(:section, :display_order, :label) }
  scope :system, -> { where(is_system: true) }
  scope :custom, -> { where(is_system: false) }
  
  # Parse JSON fields
  def required_permissions_array
    return [] if required_permissions.blank?
    required_permissions.is_a?(Array) ? required_permissions : JSON.parse(required_permissions) rescue []
  end
  
  def required_permissions_array=(array)
    self.required_permissions = array.to_json
  end
  
  def view_permissions_array
    return [] if view_permissions.blank?
    view_permissions.is_a?(Array) ? view_permissions : JSON.parse(view_permissions) rescue []
  end
  
  def view_permissions_array=(array)
    self.view_permissions = array.to_json
  end
  
  def create_permissions_array
    return [] if create_permissions.blank?
    create_permissions.is_a?(Array) ? create_permissions : JSON.parse(create_permissions) rescue []
  end
  
  def create_permissions_array=(array)
    self.create_permissions = array.to_json
  end
  
  def edit_permissions_array
    return [] if edit_permissions.blank?
    edit_permissions.is_a?(Array) ? edit_permissions : JSON.parse(edit_permissions) rescue []
  end
  
  def edit_permissions_array=(array)
    self.edit_permissions = array.to_json
  end
  
  def delete_permissions_array
    return [] if delete_permissions.blank?
    delete_permissions.is_a?(Array) ? delete_permissions : JSON.parse(delete_permissions) rescue []
  end
  
  def delete_permissions_array=(array)
    self.delete_permissions = array.to_json
  end
  
  # Check if user can perform action
  def can_perform_action?(user_or_admin, action)
    return false unless user_or_admin
    return true if user_or_admin.respond_to?(:super_admin?) && user_or_admin.super_admin?
    
    case action.to_s
    when 'view'
      return true if always_visible
      return false unless can_view
      check_permissions(user_or_admin, view_permissions_array.presence || required_permissions_array)
    when 'create'
      return false unless can_create
      check_permissions(user_or_admin, create_permissions_array.presence || required_permissions_array)
    when 'edit', 'update'
      return false unless can_edit
      check_permissions(user_or_admin, edit_permissions_array.presence || required_permissions_array)
    when 'delete', 'destroy'
      return false unless can_delete
      check_permissions(user_or_admin, delete_permissions_array.presence || required_permissions_array)
    else
      false
    end
  end
  
  # Check if user can view this navigation item
  def can_view_item?(user_or_admin)
    return false unless user_or_admin
    return true if always_visible
    return false if require_super_admin && !(user_or_admin.respond_to?(:super_admin?) && user_or_admin.super_admin?)
    
    check_permissions(user_or_admin, required_permissions_array)
  end
  
  # Get all permissions needed for this item
  def all_permissions
    perms = Set.new
    perms.merge(required_permissions_array)
    perms.merge(view_permissions_array)
    perms.merge(create_permissions_array)
    perms.merge(edit_permissions_array)
    perms.merge(delete_permissions_array)
    perms.to_a
  end
  
  private
  
  def check_permissions(user_or_admin, permission_slugs)
    return false if permission_slugs.blank?
    
    permission_slugs.any? do |slug|
      if user_or_admin.respond_to?(:has_permission?)
        user_or_admin.has_permission?(slug)
      else
        false
      end
    end
  end
end

