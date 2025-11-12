# frozen_string_literal: true

module Authentication
  class SessionService
    def self.create_session(user, request, options = {})
      device_info = extract_device_info(request)
      location_info = extract_location_info(request)
      
      session_token = generate_session_token
      
      LoginSession.create!(
        user: user,
        session_token: session_token,
        jwt_token_id: options[:jwt_token_id],
        
        # Location & Network
        ip_address: request.remote_ip,
        country: location_info[:country],
        region: location_info[:region],
        city: location_info[:city],
        timezone: location_info[:timezone] || user.try(:timezone) || 'UTC',
        
        # Device Information
        device_type: device_info[:device_type],
        device_name: device_info[:device_name],
        os_name: device_info[:os_name],
        os_version: device_info[:os_version],
        browser_name: device_info[:browser_name],
        browser_version: device_info[:browser_version],
        user_agent: request.user_agent,
        
        # Screen/Display Info
        screen_resolution: options[:screen_resolution],
        viewport_size: options[:viewport_size],
        
        # Network Info
        connection_type: options[:connection_type],
        is_mobile: device_info[:is_mobile],
        is_tablet: device_info[:is_tablet],
        is_desktop: device_info[:is_desktop],
        
        # Login Details
        login_method: options[:login_method] || 'password',
        is_successful: options[:is_successful] != false,
        failure_reason: options[:failure_reason],
        
        # Session Status
        logged_in_at: Time.current,
        last_activity_at: Time.current,
        
        # Additional Metadata
        metadata: {
          referrer: request.referer,
          request_id: request.request_id,
          forwarded_for: request.headers['X-Forwarded-For'],
          accept_language: request.headers['Accept-Language'],
          platform: options[:platform] || 'web',
          app_version: options[:app_version]
        }.to_json
      )
    rescue => e
      Rails.logger.error "Failed to create login session: #{e.message}"
      nil
    end
    
    def self.extract_device_info(request)
      user_agent = request.user_agent || ''
      
      # Parse user agent using regex (can be enhanced with a gem like user_agent_parser)
      device_info = {
        device_type: 'desktop',
        device_name: nil,
        os_name: nil,
        os_version: nil,
        browser_name: nil,
        browser_version: nil,
        is_mobile: false,
        is_tablet: false,
        is_desktop: true
      }
      
      # Detect mobile
      if user_agent.match?(/Mobile|Android|iPhone|iPad|iPod|BlackBerry|Windows Phone/i)
        device_info[:is_mobile] = true
        device_info[:device_type] = 'mobile'
        device_info[:is_desktop] = false
      end
      
      # Detect tablet
      if user_agent.match?(/iPad|Android.*Tablet|Tablet/i)
        device_info[:is_tablet] = true
        device_info[:device_type] = 'tablet'
        device_info[:is_mobile] = false
        device_info[:is_desktop] = false
      end
      
      # Detect OS
      if user_agent.match?(/Windows NT (\d+\.\d+)/)
        device_info[:os_name] = 'Windows'
        device_info[:os_version] = $1
      elsif user_agent.match?(/Mac OS X (\d+[._]\d+)/)
        device_info[:os_name] = 'macOS'
        device_info[:os_version] = $1.gsub('_', '.')
      elsif user_agent.match?(/Linux/)
        device_info[:os_name] = 'Linux'
      elsif user_agent.match?(/iPhone OS (\d+[._]\d+)/)
        device_info[:os_name] = 'iOS'
        device_info[:os_version] = $1.gsub('_', '.')
      elsif user_agent.match?(/Android (\d+\.\d+)/)
        device_info[:os_name] = 'Android'
        device_info[:os_version] = $1
      end
      
      # Detect Browser
      if user_agent.match?(/Chrome\/(\d+)/) && !user_agent.match?(/Edg|OPR/)
        device_info[:browser_name] = 'Chrome'
        device_info[:browser_version] = $1
      elsif user_agent.match?(/Safari\/(\d+)/) && !user_agent.match?(/Chrome/)
        device_info[:browser_name] = 'Safari'
        device_info[:browser_version] = $1
      elsif user_agent.match?(/Firefox\/(\d+)/)
        device_info[:browser_name] = 'Firefox'
        device_info[:browser_version] = $1
      elsif user_agent.match?(/Edg\/(\d+)/)
        device_info[:browser_name] = 'Edge'
        device_info[:browser_version] = $1
      end
      
      # Detect device name (for mobile)
      if user_agent.match?(/iPhone/)
        device_info[:device_name] = 'iPhone'
      elsif user_agent.match?(/iPad/)
        device_info[:device_name] = 'iPad'
      elsif user_agent.match?(/Macintosh/)
        device_info[:device_name] = 'Mac'
      end
      
      device_info
    end
    
    def self.extract_location_info(request)
      # This would typically use a geolocation service like MaxMind GeoIP2
      # For now, we'll return empty values - can be enhanced with IP geolocation
      {
        country: nil,
        region: nil,
        city: nil,
        timezone: nil
      }
    end
    
    def self.generate_session_token
      SecureRandom.hex(32)
    end
  end
end

