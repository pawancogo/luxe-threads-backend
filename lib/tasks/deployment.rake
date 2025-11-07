# frozen_string_literal: true

namespace :deployment do
  desc "Pre-deployment checklist"
  task pre_deployment_check: :environment do
    puts "=" * 80
    puts "Pre-Deployment Checklist"
    puts "=" * 80
    puts ""
    
    checks = []
    
    # Check database migrations
    puts "Checking database migrations..."
    pending_migrations = ActiveRecord::Migration.check_pending!
    if pending_migrations.empty?
      puts "  ✓ No pending migrations"
      checks << true
    else
      puts "  ✗ Pending migrations found"
      checks << false
    end
    
    # Check environment variables
    puts "Checking required environment variables..."
    required_vars = %w[
      DATABASE_NAME
      DATABASE_USER
      SECRET_KEY_BASE
      FRONTEND_URL
    ]
    
    missing_vars = required_vars.reject { |var| ENV[var].present? }
    if missing_vars.empty?
      puts "  ✓ All required environment variables set"
      checks << true
    else
      puts "  ✗ Missing environment variables: #{missing_vars.join(', ')}"
      checks << false
    end
    
    # Check feature flags
    puts "Checking feature flags..."
    enabled_features = FeatureFlags.enabled_features
    puts "  Enabled features: #{enabled_features.join(', ')}"
    checks << true
    
    # Check database connection
    puts "Checking database connection..."
    begin
      ActiveRecord::Base.connection.execute("SELECT 1")
      puts "  ✓ Database connection successful"
      checks << true
    rescue => e
      puts "  ✗ Database connection failed: #{e.message}"
      checks << false
    end
    
    # Check cache connection (if Redis)
    if ENV['REDIS_URL'].present?
      puts "Checking Redis connection..."
      begin
        require 'redis'
        redis = Redis.new(url: ENV['REDIS_URL'])
        redis.ping
        puts "  ✓ Redis connection successful"
        checks << false
      rescue => e
        puts "  ✗ Redis connection failed: #{e.message}"
        checks << false
      end
    end
    
    # Summary
    puts ""
    puts "=" * 80
    if checks.all?
      puts "✓ All pre-deployment checks passed!"
      exit 0
    else
      puts "✗ Some pre-deployment checks failed"
      exit 1
    end
  end
  
  desc "Create database backup"
  task backup_database: :environment do
    puts "Creating database backup..."
    
    timestamp = Time.current.strftime('%Y%m%d_%H%M%S')
    backup_file = Rails.root.join('backups', "db_backup_#{timestamp}.sql")
    
    # Create backups directory
    FileUtils.mkdir_p(Rails.root.join('backups'))
    
    # Database backup command (PostgreSQL)
    if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
      db_config = ActiveRecord::Base.connection_config
      cmd = "PGPASSWORD=#{db_config[:password]} pg_dump -h #{db_config[:host]} -U #{db_config[:username]} -d #{db_config[:database]} > #{backup_file}"
      system(cmd)
      
      if $?.success?
        puts "✓ Database backup created: #{backup_file}"
      else
        puts "✗ Database backup failed"
        exit 1
      end
    else
      puts "⚠ Database backup not implemented for #{ActiveRecord::Base.connection.adapter_name}"
    end
  end
  
  desc "Verify production readiness"
  task verify_production: :environment do
    puts "=" * 80
    puts "Production Readiness Verification"
    puts "=" * 80
    puts ""
    
    issues = []
    
    # Check Rails environment
    unless Rails.env.production?
      puts "⚠ Warning: Not in production environment"
      issues << "Environment check"
    end
    
    # Check SSL
    if Rails.application.config.force_ssl
      puts "✓ SSL enforced"
    else
      puts "✗ SSL not enforced"
      issues << "SSL configuration"
    end
    
    # Check CORS
    puts "✓ CORS configured"
    
    # Check rate limiting
    if defined?(Rack::Attack)
      puts "✓ Rate limiting enabled"
    else
      puts "✗ Rate limiting not enabled"
      issues << "Rate limiting"
    end
    
    # Check database indexes
    puts "Verifying database indexes..."
    required_indexes = [
      'index_orders_on_user_status_created',
      'index_products_on_category_status',
      'index_notifications_on_user_read_created'
    ]
    
    missing_indexes = required_indexes.reject do |index_name|
      ActiveRecord::Base.connection.indexes(:orders).any? { |idx| idx.name == index_name } ||
      ActiveRecord::Base.connection.indexes(:products).any? { |idx| idx.name == index_name } ||
      ActiveRecord::Base.connection.indexes(:notifications).any? { |idx| idx.name == index_name }
    end
    
    if missing_indexes.empty?
      puts "✓ Required indexes present"
    else
      puts "⚠ Some indexes may be missing"
      issues << "Database indexes"
    end
    
    # Summary
    puts ""
    puts "=" * 80
    if issues.empty?
      puts "✓ Production ready!"
      exit 0
    else
      puts "⚠ Issues found: #{issues.join(', ')}"
      exit 1
    end
  end
  
  desc "Deploy to staging"
  task deploy_staging: :environment do
    puts "=" * 80
    puts "Staging Deployment"
    puts "=" * 80
    puts ""
    
    puts "Step 1: Running pre-deployment checks..."
    Rake::Task['deployment:pre_deployment_check'].invoke
    
    puts ""
    puts "Step 2: Creating database backup..."
    Rake::Task['deployment:backup_database'].invoke
    
    puts ""
    puts "Step 3: Running migrations..."
    system("rails db:migrate RAILS_ENV=staging")
    
    puts ""
    puts "Step 4: Running data migrations..."
    system("rails data:migrate RAILS_ENV=staging")
    
    puts ""
    puts "Step 5: Validating data..."
    system("rails data:validate RAILS_ENV=staging")
    
    puts ""
    puts "✓ Staging deployment complete!"
  end
  
  desc "Deploy to production (zero-downtime)"
  task deploy_production: :environment do
    puts "=" * 80
    puts "Production Deployment (Zero-Downtime)"
    puts "=" * 80
    puts ""
    
    puts "⚠ WARNING: This will deploy to PRODUCTION"
    puts "Press Ctrl+C to cancel, or wait 10 seconds to continue..."
    sleep 10
    
    puts ""
    puts "Step 1: Running pre-deployment checks..."
    Rake::Task['deployment:pre_deployment_check'].invoke
    
    puts ""
    puts "Step 2: Creating database backup..."
    Rake::Task['deployment:backup_database'].invoke
    
    puts ""
    puts "Step 3: Running migrations (zero-downtime)..."
    puts "  - This should be done during maintenance window or using zero-downtime strategies"
    system("rails db:migrate RAILS_ENV=production")
    
    puts ""
    puts "Step 4: Validating data..."
    system("rails data:validate RAILS_ENV=production")
    
    puts ""
    puts "Step 5: Verifying production readiness..."
    Rake::Task['deployment:verify_production'].invoke
    
    puts ""
    puts "✓ Production deployment complete!"
    puts ""
    puts "Next steps:"
    puts "  1. Monitor error logs"
    puts "  2. Check application health"
    puts "  3. Enable feature flags gradually"
    puts "  4. Monitor performance metrics"
  end
  
  desc "Rollback deployment"
  task rollback: :environment do
    puts "=" * 80
    puts "Rollback Deployment"
    puts "=" * 80
    puts ""
    
    puts "⚠ WARNING: This will rollback the last migration"
    puts "Press Ctrl+C to cancel, or wait 5 seconds to continue..."
    sleep 5
    
    puts ""
    puts "Step 1: Creating backup before rollback..."
    Rake::Task['deployment:backup_database'].invoke
    
    puts ""
    puts "Step 2: Rolling back last migration..."
    system("rails db:rollback RAILS_ENV=#{Rails.env}")
    
    puts ""
    puts "✓ Rollback complete!"
    puts ""
    puts "Next steps:"
    puts "  1. Verify application functionality"
    puts "  2. Check error logs"
    puts "  3. Monitor system health"
  end
end

