# frozen_string_literal: true

namespace :rbac do
  desc "Assign RBAC roles to existing admins based on their legacy role"
  task assign_admin_roles: :environment do
    puts "Assigning RBAC roles to existing admins..."
    
    Admin.find_each do |admin|
      begin
        # Map legacy role to RBAC role slug
        role_slug = Rbac::RoleService.map_legacy_admin_role(admin.role)
        
        # Check if role assignment already exists
        existing_assignment = AdminRoleAssignment.find_by(
          admin: admin,
          rbac_role: RbacRole.find_by(slug: role_slug)
        )
        
        if existing_assignment
          puts "  ✓ Admin #{admin.email} already has role #{role_slug}"
          next
        end
        
        # Assign role
        Rbac::RoleService.assign_role_to_admin(
          admin: admin,
          role_slug: role_slug,
          assigned_by: admin # Self-assign for existing admins
        )
        
        puts "  ✓ Assigned role #{role_slug} to admin #{admin.email}"
      rescue => e
        puts "  ✗ Error assigning role to admin #{admin.email}: #{e.message}"
      end
    end
    
    puts "\nDone! All admins have been assigned RBAC roles."
  end
  
  desc "Assign RBAC roles to existing supplier account users based on their legacy role"
  task assign_supplier_roles: :environment do
    puts "Assigning RBAC roles to existing supplier account users..."
    
    SupplierAccountUser.find_each do |supplier_user|
      begin
        # Map legacy role to RBAC role slug
        role_slug = Rbac::RoleService.map_legacy_supplier_role(supplier_user.role)
        
        # Check if role already assigned
        if supplier_user.rbac_role&.slug == role_slug
          puts "  ✓ Supplier user #{supplier_user.user.email} already has role #{role_slug}"
          next
        end
        
        # Get owner to assign role
        owner = supplier_user.supplier_profile.owner || supplier_user.supplier_profile.user
        
        # Assign role
        Rbac::RoleService.assign_role_to_supplier_user(
          supplier_account_user: supplier_user,
          role_slug: role_slug,
          assigned_by: owner
        )
        
        puts "  ✓ Assigned role #{role_slug} to supplier user #{supplier_user.user.email}"
      rescue => e
        puts "  ✗ Error assigning role to supplier user #{supplier_user.user.email}: #{e.message}"
      end
    end
    
    puts "\nDone! All supplier users have been assigned RBAC roles."
  end
  
  desc "Assign RBAC roles to all existing users (admins + suppliers)"
  task assign_all_roles: :environment do
    puts "Assigning RBAC roles to all existing users...\n"
    
    Rake::Task['rbac:assign_admin_roles'].invoke
    puts "\n"
    Rake::Task['rbac:assign_supplier_roles'].invoke
  end
  
  desc "Clear all permission caches"
  task clear_cache: :environment do
    puts "Clearing all permission caches..."
    
    Admin.find_each do |admin|
      Rbac::PermissionCacheService.clear_admin_cache(admin.id)
    end
    
    SupplierAccountUser.find_each do |supplier_user|
      Rbac::PermissionCacheService.clear_supplier_user_cache(supplier_user.id)
    end
    
    puts "Done! All permission caches cleared."
  end
  
  desc "Verify RBAC setup"
  task verify: :environment do
    puts "Verifying RBAC setup...\n"
    
    # Check roles
    admin_roles = RbacRole.where(role_type: ['admin', 'system']).count
    supplier_roles = RbacRole.where(role_type: ['supplier', 'system']).count
    puts "  ✓ Admin roles: #{admin_roles}"
    puts "  ✓ Supplier roles: #{supplier_roles}"
    
    # Check permissions
    permissions = RbacPermission.count
    puts "  ✓ Permissions: #{permissions}"
    
    # Check role assignments
    admin_assignments = AdminRoleAssignment.count
    supplier_assignments = SupplierAccountUser.where.not(rbac_role_id: nil).count
    puts "  ✓ Admin role assignments: #{admin_assignments}"
    puts "  ✓ Supplier role assignments: #{supplier_assignments}"
    
    # Check admins without roles
    admins_without_roles = Admin.left_joins(:admin_role_assignments)
                               .where(admin_role_assignments: { id: nil })
                               .count
    if admins_without_roles > 0
      puts "  ⚠ Admins without RBAC roles: #{admins_without_roles}"
      puts "     Run: rake rbac:assign_admin_roles"
    else
      puts "  ✓ All admins have RBAC roles"
    end
    
    # Check supplier users without roles
    supplier_users_without_roles = SupplierAccountUser.where(rbac_role_id: nil).count
    if supplier_users_without_roles > 0
      puts "  ⚠ Supplier users without RBAC roles: #{supplier_users_without_roles}"
      puts "     Run: rake rbac:assign_supplier_roles"
    else
      puts "  ✓ All supplier users have RBAC roles"
    end
    
    puts "\nRBAC verification complete!"
  end
end

