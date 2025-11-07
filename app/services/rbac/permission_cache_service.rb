# frozen_string_literal: true

module Rbac
  # Caching service for permissions (memoization with Redis-ready interface)
  class PermissionCacheService
    class << self
      # Cache prefix
      CACHE_PREFIX = 'rbac:permissions'
      CACHE_TTL = 1.hour
      
      # Get cached permission for admin
      def get_admin_permission(admin_id, permission_slug)
        key = admin_permission_key(admin_id, permission_slug)
        
        if redis_available?
          redis.get(key) == 'true'
        else
          Rails.cache.read(key) == 'true'
        end
      rescue => e
        Rails.logger.warn "Permission cache read error: #{e.message}"
        nil
      end
      
      # Set cached permission for admin
      def set_admin_permission(admin_id, permission_slug, granted)
        key = admin_permission_key(admin_id, permission_slug)
        value = granted ? 'true' : 'false'
        
        if redis_available?
          redis.setex(key, CACHE_TTL.to_i, value)
        else
          Rails.cache.write(key, value, expires_in: CACHE_TTL)
        end
      rescue => e
        Rails.logger.warn "Permission cache write error: #{e.message}"
      end
      
      # Get all cached permissions for admin
      def get_admin_all_permissions(admin_id)
        key = admin_all_permissions_key(admin_id)
        
        if redis_available?
          data = redis.get(key)
          JSON.parse(data) if data
        else
          Rails.cache.read(key)
        end
      rescue => e
        Rails.logger.warn "Permission cache read error: #{e.message}"
        nil
      end
      
      # Set all cached permissions for admin
      def set_admin_all_permissions(admin_id, permissions)
        key = admin_all_permissions_key(admin_id)
        value = permissions.to_json
        
        if redis_available?
          redis.setex(key, CACHE_TTL.to_i, value)
        else
          Rails.cache.write(key, permissions, expires_in: CACHE_TTL)
        end
      rescue => e
        Rails.logger.warn "Permission cache write error: #{e.message}"
      end
      
      # Clear all cache for an admin
      def clear_admin_cache(admin_id)
        pattern = "#{CACHE_PREFIX}:admin:#{admin_id}:*"
        
        if redis_available?
          keys = redis.keys(pattern)
          redis.del(*keys) if keys.any?
        else
          # Rails.cache doesn't support pattern deletion, so we'll clear on next access
          Rails.cache.delete_matched(pattern)
        end
      rescue => e
        Rails.logger.warn "Permission cache clear error: #{e.message}"
      end
      
      # Get cached permission for supplier user
      def get_supplier_user_permission(supplier_user_id, permission_slug)
        key = supplier_user_permission_key(supplier_user_id, permission_slug)
        
        if redis_available?
          redis.get(key) == 'true'
        else
          Rails.cache.read(key) == 'true'
        end
      rescue => e
        Rails.logger.warn "Permission cache read error: #{e.message}"
        nil
      end
      
      # Set cached permission for supplier user
      def set_supplier_user_permission(supplier_user_id, permission_slug, granted)
        key = supplier_user_permission_key(supplier_user_id, permission_slug)
        value = granted ? 'true' : 'false'
        
        if redis_available?
          redis.setex(key, CACHE_TTL.to_i, value)
        else
          Rails.cache.write(key, value, expires_in: CACHE_TTL)
        end
      rescue => e
        Rails.logger.warn "Permission cache write error: #{e.message}"
      end
      
      # Clear all cache for a supplier user
      def clear_supplier_user_cache(supplier_user_id)
        pattern = "#{CACHE_PREFIX}:supplier_user:#{supplier_user_id}:*"
        
        if redis_available?
          keys = redis.keys(pattern)
          redis.del(*keys) if keys.any?
        else
          Rails.cache.delete_matched(pattern)
        end
      rescue => e
        Rails.logger.warn "Permission cache clear error: #{e.message}"
      end
      
      private
      
      def admin_permission_key(admin_id, permission_slug)
        "#{CACHE_PREFIX}:admin:#{admin_id}:#{permission_slug}"
      end
      
      def admin_all_permissions_key(admin_id)
        "#{CACHE_PREFIX}:admin:#{admin_id}:all"
      end
      
      def supplier_user_permission_key(supplier_user_id, permission_slug)
        "#{CACHE_PREFIX}:supplier_user:#{supplier_user_id}:#{permission_slug}"
      end
      
      def redis_available?
        defined?(Redis) && redis.present?
      rescue
        false
      end
      
      def redis
        @redis ||= Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379/0')
      rescue
        nil
      end
    end
  end
end

