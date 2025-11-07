# frozen_string_literal: true

# Feature Flags Configuration
# Enables gradual rollout of features and easy rollback

module FeatureFlags
  # Feature flags are stored in environment variables
  # Format: FEATURE_FLAG_NAME=true/false
  
  # Check if a feature is enabled
  def self.enabled?(feature_name)
    env_var = "FEATURE_#{feature_name.to_s.upcase}"
    ENV.fetch(env_var, 'false').downcase == 'true'
  end
  
  # Feature flag definitions
  FEATURES = {
    # Phase 1 features
    multi_user_supplier_accounts: {
      description: 'Enable multi-user supplier accounts',
      default: true,
      env_var: 'FEATURE_MULTI_USER_SUPPLIER_ACCOUNTS'
    },
    
    # Phase 2 features
    new_payment_system: {
      description: 'Enable new payment system (Phase 3 tables)',
      default: true,
      env_var: 'FEATURE_NEW_PAYMENT_SYSTEM'
    },
    
    enhanced_analytics: {
      description: 'Enable enhanced analytics tracking (Phase 4)',
      default: true,
      env_var: 'FEATURE_ENHANCED_ANALYTICS'
    },
    
    # Phase 4 features
    new_notification_system: {
      description: 'Enable new notification system (Phase 4)',
      default: true,
      env_var: 'FEATURE_NEW_NOTIFICATION_SYSTEM'
    },
    
    support_tickets: {
      description: 'Enable support ticket system (Phase 4)',
      default: true,
      env_var: 'FEATURE_SUPPORT_TICKETS'
    },
    
    loyalty_points: {
      description: 'Enable loyalty points system (Phase 4)',
      default: true,
      env_var: 'FEATURE_LOYALTY_POINTS'
    },
    
    product_views_tracking: {
      description: 'Enable product views tracking (Phase 4)',
      default: true,
      env_var: 'FEATURE_PRODUCT_VIEWS_TRACKING'
    },
    
    # Performance features
    caching: {
      description: 'Enable caching for product listings',
      default: true,
      env_var: 'FEATURE_CACHING'
    },
    
    # Background jobs
    async_emails: {
      description: 'Enable async email sending',
      default: false,
      env_var: 'FEATURE_ASYNC_EMAILS'
    },
    
    async_analytics: {
      description: 'Enable async analytics processing',
      default: false,
      env_var: 'FEATURE_ASYNC_ANALYTICS'
    }
  }.freeze
  
  # Helper method to check feature
  def self.check(feature_name)
    feature = FEATURES[feature_name.to_sym]
    return false unless feature
    
    env_var = feature[:env_var]
    ENV.fetch(env_var, feature[:default].to_s).to_s.downcase == 'true'
  end
  
  # Get all enabled features
  def self.enabled_features
    FEATURES.keys.select { |feature| check(feature) }
  end
  
  # Get all disabled features
  def self.disabled_features
    FEATURES.keys.reject { |feature| check(feature) }
  end
  
  # Feature flag helper for controllers
  def self.require_feature!(feature_name)
    unless check(feature_name)
      raise FeatureNotEnabledError, "Feature '#{feature_name}' is not enabled"
    end
  end
end

# Custom error for disabled features
class FeatureNotEnabledError < StandardError; end

# Helper method for controllers
module FeatureFlagHelper
  def feature_enabled?(feature_name)
    FeatureFlags.check(feature_name)
  end
  
  def require_feature!(feature_name)
    FeatureFlags.require_feature!(feature_name)
  end
end

# Include in ApplicationController
ActionController::API.include(FeatureFlagHelper)

