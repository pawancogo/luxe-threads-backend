# System Configurations Setup

## Create Navigation Item

To make the System Configurations menu appear in the admin UI, run one of the following:

### Option 1: Using Rails Console
```bash
rails console
```

Then run:
```ruby
NavigationItem.find_or_create_by(key: 'system_configurations') do |item|
  item.label = 'System Configurations'
  item.icon = 'fas fa-sliders-h'
  item.path_method = 'admin_system_configurations_path'
  item.section = 'System'
  item.required_permissions = ['system_configurations:view', 'system_configurations:read'].to_json
  item.require_super_admin = false
  item.can_view = true
  item.can_create = true
  item.can_edit = true
  item.can_delete = true
  item.view_permissions = ['system_configurations:view'].to_json
  item.create_permissions = ['system_configurations:create'].to_json
  item.edit_permissions = ['system_configurations:update', 'system_configurations:edit'].to_json
  item.delete_permissions = ['system_configurations:delete', 'system_configurations:destroy'].to_json
  item.display_order = 3
  item.is_system = true
  item.controller_name = 'system_configurations'
  item.description = 'Manage system configurations (key-value pairs)'
  item.is_active = true
end
```

### Option 2: Using Rake Task
```bash
rails system_configurations:create_navigation_item
```

## Role-Based Filtering

The System Configurations feature includes automatic role-based filtering:

- **Super Admins**: Can see all configurations created by any admin
- **Other Admins**: Can only see configurations created by admins with the same role

For example:
- A `product_admin` can only see configurations created by other `product_admin` users
- A `order_admin` can only see configurations created by other `order_admin` users
- `super_admin` can see all configurations

This filtering happens automatically in the controller - no additional configuration needed.

## Run Migration

Don't forget to run the migration:
```bash
rails db:migrate
```

