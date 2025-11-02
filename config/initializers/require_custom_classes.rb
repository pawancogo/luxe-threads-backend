# frozen_string_literal: true

# Explicitly require custom classes to ensure they're loaded
# This runs after Rails is initialized to guarantee Rails.root is available
Rails.application.config.to_prepare do
  base = Rails.root.join('app')
  
  # Require all files in custom directories
  [
    base.join('repositories', '*.rb'),
    base.join('presenters', '*.rb'),
    base.join('forms', '*.rb'),
    base.join('queries', '*.rb'),
    base.join('services', '*.rb'),
    base.join('value_objects', '*.rb')
  ].each do |pattern|
    Dir[pattern].each do |file|
      require file
    end
  end
rescue LoadError, StandardError => e
  Rails.logger.error "Failed to load custom classes: #{e.message}"
  Rails.logger.error e.backtrace.join("\n")
end

