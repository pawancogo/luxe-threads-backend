# frozen_string_literal: true

module Authentication
  class TempPasswordService
    # Configuration constants
    PASSWORD_LENGTH = 12
    EXPIRY_HOURS = 24
    
    def self.generate
      # Generate a secure temporary password that meets requirements
      # 12 characters: 2 uppercase, 2 lowercase, 2 numbers, 2 special chars, 4 random
      uppercase = ('A'..'Z').to_a.sample(2).join
      lowercase = ('a'..'z').to_a.sample(2).join
      numbers = (0..9).to_a.sample(2).join
      special = ['!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+', '-', '='].sample(2).join
      random = (('A'..'Z').to_a + ('a'..'z').to_a + (0..9).to_a).sample(4).join
      
      # Shuffle all parts together
      (uppercase + lowercase + numbers + special + random).split('').shuffle.join
    end
    
    # Generate secure token for password reset
    def self.generate_token
      SecureRandom.urlsafe_base64(32)
    end
    
    # Generic method that works for any model with temp_password_digest field
    def self.generate_for(model)
      temp_password = generate
      # Hash the temporary password with argon2
      temp_password_digest = Authentication::PasswordHashingService.hash_password(temp_password)
      
      # Generate secure token for password reset URL
      reset_token = generate_token
      
      model.update!(
        temp_password_digest: temp_password_digest,
        temp_password_expires_at: EXPIRY_HOURS.hours.from_now,
        password_reset_required: true,
        password_reset_token: reset_token,
        password_reset_token_expires_at: EXPIRY_HOURS.hours.from_now
      )
      { temp_password: temp_password, token: reset_token }
    end
    
    # Generic authentication method
    def self.authenticate_temp_password(model, temp_password)
      return false if model.temp_password_digest.blank?
      return false if model.temp_password_expires_at.blank? || model.temp_password_expires_at < Time.current
      
      Authentication::PasswordHashingService.verify_password(temp_password, model.temp_password_digest)
    end
    
    # Check if temp password is expired
    def self.temp_password_expired?(model)
      model.temp_password_expires_at.present? && model.temp_password_expires_at < Time.current
    end
    
    # Clear temp password after successful reset
    def self.clear_temp_password(model)
      model.update!(
        temp_password_digest: nil,
        temp_password_expires_at: nil,
        password_reset_required: false,
        password_reset_token: nil,
        password_reset_token_expires_at: nil
      )
    end
    
    # Verify password reset token
    def self.verify_reset_token(model, token)
      return false if model.password_reset_token.blank?
      return false if token.blank?
      return false if model.password_reset_token_expires_at.blank? || model.password_reset_token_expires_at < Time.current
      
      ActiveSupport::SecurityUtils.secure_compare(model.password_reset_token, token)
    end
  end
end

