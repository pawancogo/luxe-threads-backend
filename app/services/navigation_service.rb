# frozen_string_literal: true

# Service for managing dynamic navigation based on RBAC permissions
# Reads navigation items from database for fully dynamic management
class NavigationService
  class << self
    # Get visible navigation items for a user/admin (from database)
    def visible_items(user_or_admin)
      return {} unless user_or_admin

      # Get all active navigation items from database
      nav_items = NavigationItem.active.ordered
      
      # Filter items user can view
      visible_items = nav_items.select do |item|
        item.can_view_item?(user_or_admin)
      end
      
      # Convert to hash format and organize by section
      items_hash = visible_items.map do |item|
        {
          key: item.key.to_sym,
          label: item.label,
          icon: item.icon,
          path: item.path_method.to_sym,
          section: item.section,
          can_view: item.can_view,
          can_create: item.can_create,
          can_edit: item.can_edit,
          can_delete: item.can_delete,
          controller_name: item.controller_name
        }
      end
      
      # Organize by sections
      organize_by_sections(items_hash)
    end

    # Check if user can view a specific navigation item
    def can_view?(user_or_admin, item_key)
      return false unless user_or_admin
      
      item = NavigationItem.active.find_by(key: item_key.to_s)
      return false unless item
      
      item.can_view_item?(user_or_admin)
    end
    
    # Check if user can perform action on navigation item
    def can_perform_action?(user_or_admin, item_key, action)
      return false unless user_or_admin
      
      item = NavigationItem.active.find_by(key: item_key.to_s)
      return false unless item
      
      item.can_perform_action?(user_or_admin, action)
    end

    # Get navigation item configuration
    def get_item(item_key)
      NavigationItem.active.find_by(key: item_key.to_s)
    end

    private

    # Organize items by sections
    def organize_by_sections(items)
      result = {}
      
      items.each do |item|
        section = item[:section] || 'Other'
        result[section] ||= []
        result[section] << item
      end

      # Sort sections by display order (maintain order from database)
      sorted_result = {}
      sections = result.keys.sort
      
      sections.each do |section|
        sorted_result[section] = result[section].sort_by { |item| item[:key].to_s }
      end

      sorted_result
    end
  end
end

