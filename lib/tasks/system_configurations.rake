# frozen_string_literal: true

namespace :system_configurations do
  desc "Create navigation item for System Configurations"
  task create_navigation_item: :environment do
    NavigationItem.find_or_create_by(key: 'system_configurations') do |item|
      item.label = 'System Configurations'
      item.icon = 'fas fa-sliders-h'
      item.path_method = 'admin_system_configurations_path'
      item.section = 'System'
      # Empty permissions array - will be visible to all admins since we check access in controller
      item.required_permissions = [].to_json
      item.require_super_admin = false  # All admins can access, but filtered by role in controller
      # Set always_visible to true so it shows up (permissions are checked in controller anyway)
      item.always_visible = true
      item.can_view = true
      item.can_create = true
      item.can_edit = true
      item.can_delete = true
      item.view_permissions = [].to_json
      item.create_permissions = [].to_json
      item.edit_permissions = [].to_json
      item.delete_permissions = [].to_json
      item.display_order = 3
      item.is_system = true
      item.controller_name = 'system_configurations'
      item.description = 'Manage system configurations (key-value pairs)'
      item.is_active = true
    end
    
    puts "✓ System Configurations navigation item created/updated successfully!"
  end
end

