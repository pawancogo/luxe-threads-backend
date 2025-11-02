# frozen_string_literal: true

# Ensure validators are loaded before RailsAdmin tries to introspect models
# In development, eager loading is disabled, so we need to explicitly load validators
Rails.application.config.to_prepare do
  # Load all validators to ensure they're available when models are introspected
  Dir[Rails.root.join('app', 'validators', '**', '*.rb')].each do |validator_file|
    load validator_file
  end
end

