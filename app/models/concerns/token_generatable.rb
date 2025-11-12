# frozen_string_literal: true

# Concern for models that need to generate secure tokens
# Provides token generation with uniqueness checking
module TokenGeneratable
  extend ActiveSupport::Concern

  module ClassMethods
    # Generate a unique token for the given field
    # Usage: generate_unique_token(:verification_token)
    def generate_unique_token(field_name, length: 32, method: :urlsafe_base64)
      loop do
        token = SecureRandom.public_send(method, length)
        break token unless exists?(field_name => token)
      end
    end
  end

  # Generate a secure token using urlsafe_base64
  # Usage: generate_token or generate_token(length: 64)
  def generate_token(length: 32, method: :urlsafe_base64)
    SecureRandom.public_send(method, length)
  end

  # Generate a unique token for a specific field
  # Usage: generate_unique_token_for(:verification_token)
  def generate_unique_token_for(field_name, length: 32, method: :urlsafe_base64)
    self.class.generate_unique_token(field_name, length: length, method: method)
  end
end

