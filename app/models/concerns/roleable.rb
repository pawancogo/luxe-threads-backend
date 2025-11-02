# frozen_string_literal: true

# Concern for models with roles
# Extracts role-related helper methods
module Roleable
  extend ActiveSupport::Concern

  # Helper methods for role checking
  # Models can override these as needed
  def premium?
    false # Default implementation, override in models
  end

  def vip?
    false # Default implementation, override in models
  end
end

