# frozen_string_literal: true

namespace :rollback do
  desc "Rollback to previous database version"
  task database: :environment do
    puts "=" * 80
    puts "Database Rollback"
    puts "=" * 80
    puts ""
    
    puts "⚠ WARNING: This will rollback database migrations"
    puts "Current version: #{ActiveRecord::Migrator.current_version}"
    puts ""
    puts "Press Ctrl+C to cancel, or wait 5 seconds to continue..."
    sleep 5
    
    puts ""
    puts "Step 1: Creating backup before rollback..."
    Rake::Task['deployment:backup_database'].invoke
    
    puts ""
    puts "Step 2: Rolling back one migration..."
    system("rails db:rollback STEP=1")
    
    puts ""
    puts "✓ Database rollback complete!"
  end
  
  desc "Disable all feature flags (emergency)"
  task disable_all_features: :environment do
    puts "Disabling all feature flags..."
    
    FeatureFlags::FEATURES.each_key do |feature|
      ENV["FEATURE_#{feature.to_s.upcase}"] = 'false'
      puts "  Disabled: #{feature}"
    end
    
    puts "✓ All feature flags disabled"
  end
  
  desc "Rollback to specific migration version"
  task :to_version, [:version] => :environment do |_t, args|
    version = args[:version]
    
    unless version
      puts "Usage: rails rollback:to_version[VERSION]"
      exit 1
    end
    
    puts "Rolling back to version: #{version}"
    puts "⚠ WARNING: This will rollback to a specific migration version"
    puts "Press Ctrl+C to cancel, or wait 5 seconds to continue..."
    sleep 5
    
    system("rails db:migrate:down VERSION=#{version}")
    puts "✓ Rollback complete"
  end
end

