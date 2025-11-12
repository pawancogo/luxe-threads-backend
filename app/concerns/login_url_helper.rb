# frozen_string_literal: true

# Concern for building login URLs based on user type
# Used in mailers and services to generate correct login URLs
module LoginUrlHelper
  extend ActiveSupport::Concern

  # Get login URL based on user type
  # @param user_type [String] 'admin', 'supplier', or 'user'
  # @return [String] Full URL to the appropriate login page
  def login_url_for_user_type(user_type)
    case user_type.to_s.downcase
    when 'admin'
      admin_login_url
    when 'supplier'
      supplier_login_url
    else
      user_login_url
    end
  end

  # Build admin login URL using backend URL
  # Admin always uses backend, not frontend
  # @return [String] Backend admin login URL
  def admin_login_url
    protocol = Rails.env.production? ? 'https' : 'http'
    default_options = Rails.application.config.action_mailer.default_url_options
    host = default_options[:host] || 'localhost'
    port = default_options[:port] || 3000
    
    base_url = if Rails.env.production?
      host
    else
      "#{host}:#{port}"
    end
    
    "#{protocol}://#{base_url}/admin/login"
  end

  # Build supplier login URL using frontend URL
  # Suppliers use frontend portal
  # @return [String] Frontend supplier login URL
  def supplier_login_url
    build_frontend_url('/supplier/login')
  end

  # Build user/customer login URL using frontend URL
  # Customers use frontend
  # @return [String] Frontend user login URL
  def user_login_url
    build_frontend_url('/login')
  end

  # Build admin login with temp password URL using backend URL
  # Used in password reset emails to direct admin to temp password login page
  # @return [String] Backend admin login with temp password URL
  def admin_login_with_temp_password_url
    protocol = Rails.env.production? ? 'https' : 'http'
    default_options = Rails.application.config.action_mailer.default_url_options
    host = default_options[:host] || 'localhost'
    port = default_options[:port] || 3000
    
    base_url = if Rails.env.production?
      host
    else
      "#{host}:#{port}"
    end
    
    "#{protocol}://#{base_url}/admin_auth/login_with_temp_password?user_type=admin"
  end

  private

  # Build frontend URL helper
  # @param path [String] Path to append to frontend URL
  # @return [String] Full frontend URL with path
  def build_frontend_url(path)
    frontend_url = ENV.fetch('FRONTEND_URL', 'http://localhost:8080')
    # Remove trailing slash if present
    frontend_url = frontend_url.chomp('/')
    # Ensure path starts with /
    path = "/#{path}" unless path.start_with?('/')
    "#{frontend_url}#{path}"
  end
end

