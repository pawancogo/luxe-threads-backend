# Run this in Rails console: rails console
# Then: load 'create_nav_item.rb'

item = NavigationItem.find_or_initialize_by(key: 'system_configurations')
item.label = 'System Configurations'
item.icon = 'fas fa-sliders-h'
item.path_method = 'admin_system_configurations_path'
item.section = 'System'
# Set empty permissions array so it's visible to all admins (permissions checked in controller)
# Empty permissions array - will be visible to all admins since we check access in controller
item.required_permissions = [].to_json
item.require_super_admin = false
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
item.save!

puts "✓ System Configurations navigation item created/updated successfully!"
puts "  Key: #{item.key}"
puts "  Section: #{item.section}"
puts "  Active: #{item.is_active}"
puts "  Require Super Admin: #{item.require_super_admin}"

