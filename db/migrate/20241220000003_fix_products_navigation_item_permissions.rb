class FixProductsNavigationItemPermissions < ActiveRecord::Migration[7.0]
  def up
    # Fix navigation items to remove non-existent :read permissions
    # Products
    products_item = NavigationItem.find_by(key: 'products')
    if products_item
      products_item.update!(required_permissions: ['products:view'].to_json)
    end
    
    # Categories
    categories_item = NavigationItem.find_by(key: 'categories')
    if categories_item
      categories_item.update!(required_permissions: ['categories:view', 'products:view'].to_json)
    end
    
    # Orders
    orders_item = NavigationItem.find_by(key: 'orders')
    if orders_item
      orders_item.update!(required_permissions: ['orders:view'].to_json)
    end
    
    # Users/Customers - use only users:view since customers:view might not exist
    users_item = NavigationItem.find_by(key: 'users')
    if users_item
      users_item.update!(required_permissions: ['users:view'].to_json)
    end
    
    # Suppliers
    suppliers_item = NavigationItem.find_by(key: 'suppliers')
    if suppliers_item
      suppliers_item.update!(required_permissions: ['suppliers:view'].to_json)
    end
  end

  def down
    # Revert to original permissions
    products_item = NavigationItem.find_by(key: 'products')
    products_item&.update!(required_permissions: ['products:view', 'products:read'].to_json)
    
    categories_item = NavigationItem.find_by(key: 'categories')
    categories_item&.update!(required_permissions: ['categories:view', 'categories:read', 'products:view'].to_json)
    
    orders_item = NavigationItem.find_by(key: 'orders')
    orders_item&.update!(required_permissions: ['orders:view', 'orders:read'].to_json)
    
    users_item = NavigationItem.find_by(key: 'users')
    users_item&.update!(required_permissions: ['users:view', 'customers:view', 'users:read'].to_json)
    
    suppliers_item = NavigationItem.find_by(key: 'suppliers')
    suppliers_item&.update!(required_permissions: ['suppliers:view', 'suppliers:read'].to_json)
  end
end

