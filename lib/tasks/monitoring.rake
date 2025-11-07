# frozen_string_literal: true

namespace :monitoring do
  desc "Check application health"
  task health_check: :environment do
    checks = {
      database: false,
      cache: false,
      migrations: false
    }
    
    # Check database
    begin
      ActiveRecord::Base.connection.execute("SELECT 1")
      checks[:database] = true
    rescue => e
      puts "✗ Database: #{e.message}"
    end
    
    # Check cache
    begin
      Rails.cache.write('health_check', 'ok', expires_in: 1.second)
      checks[:cache] = Rails.cache.read('health_check') == 'ok'
    rescue => e
      puts "✗ Cache: #{e.message}"
    end
    
    # Check migrations
    begin
      ActiveRecord::Migration.check_pending!
      checks[:migrations] = true
    rescue => e
      puts "✗ Migrations: #{e.message}"
    end
    
    # Output results
    if checks.values.all?
      puts "✓ All health checks passed"
      exit 0
    else
      puts "✗ Some health checks failed"
      exit 1
    end
  end
  
  desc "Show application metrics"
  task metrics: :environment do
    puts "=" * 80
    puts "Application Metrics"
    puts "=" * 80
    puts ""
    
    # Database metrics
    puts "Database:"
    puts "  Users: #{User.count}"
    puts "  Products: #{Product.count}"
    puts "  Orders: #{Order.count}"
    puts "  Active Products: #{Product.active.count}"
    puts ""
    
    # Feature flags
    puts "Feature Flags:"
    FeatureFlags.enabled_features.each do |feature|
      puts "  ✓ #{feature}"
    end
    puts ""
    
    # Cache stats (if Redis)
    if ENV['REDIS_URL'].present?
      begin
        require 'redis'
        redis = Redis.new(url: ENV['REDIS_URL'])
        puts "Redis:"
        puts "  Connected: ✓"
        puts "  Memory: #{redis.info['used_memory_human']}"
      rescue => e
        puts "Redis: ✗ #{e.message}"
      end
    end
    
    puts ""
  end
  
  desc "Check error rates"
  task check_errors: :environment do
    # Check recent errors in logs
    log_file = Rails.root.join('log', "#{Rails.env}.log")
    if File.exist?(log_file)
      recent_errors = `tail -n 1000 #{log_file} | grep -i "error" | wc -l`.to_i
      puts "Recent errors (last 1000 log lines): #{recent_errors}"
    end
  end
end

