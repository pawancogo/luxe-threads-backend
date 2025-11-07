namespace :data do
  desc "Migrate Supplier records to User records"
  task migrate_suppliers: :environment do
    puts "🚀 Starting Supplier to User migration..."
    
    # Get all suppliers
    suppliers = ActiveRecord::Base.connection.execute("SELECT * FROM suppliers")
    total_count = suppliers.count
    migrated_count = 0
    skipped_count = 0
    error_count = 0
    
    puts "Found #{total_count} suppliers to migrate"
    
    ActiveRecord::Base.transaction do
      suppliers.each do |supplier|
        begin
          email = supplier['email']
          puts "\n📋 Processing supplier: #{email}"
          
          # Check if user already exists with this email
          existing_user = User.find_by(email: email)
          
          if existing_user
            puts "  ✅ User already exists: #{email}"
            
            # Update user role to supplier if not already
            if existing_user.role != 'supplier'
              existing_user.update!(role: 'supplier')
              puts "  ✅ Updated user role to 'supplier'"
            end
            
            # Update supplier_profile to link to this user
            supplier_profile = SupplierProfile.find_by(supplier_id: supplier['id'])
            if supplier_profile
              supplier_profile.update!(
                owner_id: existing_user.id,
                user_id: existing_user.id,
                migration_status: 'completed'
              )
              puts "  ✅ Linked supplier_profile to existing user"
              
              # Create supplier account user record
              if ActiveRecord::Base.connection.table_exists?('supplier_account_users')
                SupplierAccountUser.find_or_create_by!(
                  supplier_profile_id: supplier_profile.id,
                  user_id: existing_user.id
                ) do |sau|
                  sau.role = 'owner'
                  sau.status = 'active'
                  sau.can_manage_products = true
                  sau.can_manage_orders = true
                  sau.can_view_financials = true
                  sau.can_manage_users = true
                  sau.can_manage_settings = true
                  sau.can_view_analytics = true
                  sau.accepted_at = supplier_profile.created_at
                end
                puts "  ✅ Created supplier account user (owner)"
              end
            end
          else
            # Create new user from supplier
            puts "  🔄 Creating new user from supplier..."
            
            # Map supplier role to supplier_tier
            supplier_tier = case supplier['role']
            when 'basic_supplier'
              'basic'
            when 'verified_supplier'
              'verified'
            when 'premium_supplier'
              'premium'
            when 'partner_supplier'
              'partner'
            else
              'basic'
            end
            
            # Create user without validations (password_digest already exists)
            new_user = User.new(
              first_name: supplier['first_name'],
              last_name: supplier['last_name'],
              email: supplier['email'],
              phone_number: supplier['phone_number'],
              password_digest: supplier['password_digest'],
              role: 'supplier',
              email_verified: supplier['email_verified'],
              temp_password_digest: supplier['temp_password_digest'],
              temp_password_expires_at: supplier['temp_password_expires_at'],
              password_reset_required: supplier['password_reset_required'],
              created_at: supplier['created_at'],
              updated_at: supplier['updated_at']
            )
            new_user.save!(validate: false)
            
            puts "  ✅ Created user: #{new_user.email}"
            
            # Update supplier_profile
            supplier_profile = SupplierProfile.find_by(supplier_id: supplier['id'])
            if supplier_profile
              supplier_profile.update!(
                owner_id: new_user.id,
                user_id: new_user.id,
                supplier_tier: supplier_tier,
                migration_status: 'completed'
              )
              puts "  ✅ Linked supplier_profile and set tier: #{supplier_tier}"
              
              # Create supplier account user record
              if ActiveRecord::Base.connection.table_exists?('supplier_account_users')
                SupplierAccountUser.find_or_create_by!(
                  supplier_profile_id: supplier_profile.id,
                  user_id: new_user.id
                ) do |sau|
                  sau.role = 'owner'
                  sau.status = 'active'
                  sau.can_manage_products = true
                  sau.can_manage_orders = true
                  sau.can_view_financials = true
                  sau.can_manage_users = true
                  sau.can_manage_settings = true
                  sau.can_view_analytics = true
                  sau.accepted_at = supplier_profile.created_at
                end
                puts "  ✅ Created supplier account user (owner)"
              end
            else
              puts "  ⚠️  No supplier_profile found for supplier #{supplier['id']}"
            end
          end
          
          migrated_count += 1
          puts "  ✅ Migration completed for #{email}"
          
        rescue => e
          error_count += 1
          puts "  ❌ Error migrating supplier #{supplier['email']}: #{e.message}"
          puts "  #{e.backtrace.first(3).join("\n  ")}"
        end
      end
    end
    
    puts "\n" + "="*60
    puts "📊 Migration Summary"
    puts "="*60
    puts "Total suppliers: #{total_count}"
    puts "Migrated: #{migrated_count}"
    puts "Skipped: #{skipped_count}"
    puts "Errors: #{error_count}"
    puts "="*60
    
    if error_count > 0
      puts "\n⚠️  Some suppliers failed to migrate. Please review errors above."
      exit 1
    else
      puts "\n✅ All suppliers migrated successfully!"
    end
  end
  
  desc "Verify supplier migration (alias for migrate_suppliers)"
  task migrate_suppliers_to_users: :environment do
    Rake::Task['data:migrate_suppliers'].invoke
  end
  
  desc "Verify supplier migration"
  task verify_supplier_migration: :environment do
    puts "🔍 Verifying supplier migration..."
    
    supplier_count = ActiveRecord::Base.connection.execute("SELECT COUNT(*) FROM suppliers").first['count'].to_i
    user_supplier_count = User.where(role: 'supplier').count
    supplier_profile_count = SupplierProfile.count
    supplier_profiles_with_owner = SupplierProfile.where.not(owner_id: nil).count
    
    puts "\n📊 Verification Results:"
    puts "  Suppliers in suppliers table: #{supplier_count}"
    puts "  Users with supplier role: #{user_supplier_count}"
    puts "  Total supplier_profiles: #{supplier_profile_count}"
    puts "  Supplier_profiles with owner_id: #{supplier_profiles_with_owner}"
    
    if supplier_count == 0 && user_supplier_count > 0 && supplier_profiles_with_owner == supplier_profile_count
      puts "\n✅ Migration verification passed!"
    else
      puts "\n⚠️  Migration verification failed. Please check the data."
      
      if supplier_count > 0
        puts "  ❌ Suppliers table still has #{supplier_count} records"
      end
      
      if supplier_profiles_with_owner < supplier_profile_count
        missing = supplier_profile_count - supplier_profiles_with_owner
        puts "  ❌ #{missing} supplier_profiles missing owner_id"
      end
    end
  end
end

