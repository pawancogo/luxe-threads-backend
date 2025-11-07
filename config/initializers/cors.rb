# Be sure to restart your server when you modify this file.

# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Restrict origins in production, allow all in development
    origins Rails.env.production? ? ENV.fetch('FRONTEND_URL', 'https://yourdomain.com').split(',') : '*'
    
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ['Authorization'],
      credentials: Rails.env.production? # Enable credentials in production
  end
end

