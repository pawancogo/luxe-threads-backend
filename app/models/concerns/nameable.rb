# frozen_string_literal: true

# Concern for models with first_name and last_name that need full_name
# Extracts name formatting logic
module Nameable
  extend ActiveSupport::Concern

  # Generate full name from first_name and last_name
  def full_name
    parts = [first_name, last_name].compact.reject(&:blank?)
    parts.any? ? parts.join(' ') : nil
  end
end

