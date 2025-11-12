# frozen_string_literal: true

module Authentication
  class PasswordValidationService
    def self.valid?(password)
      return false if password.blank?
      return false if password.length < 8
      
      # Check for at least one uppercase letter
      return false unless password.match?(/[A-Z]/)
      
      # Check for at least one lowercase letter
      return false unless password.match?(/[a-z]/)
      
      # Check for at least one number
      return false unless password.match?(/\d/)
      
      # Check for at least one special character
      return false unless password.match?(/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/)
      
      true
    end
    
    def self.errors(password)
      errors = []
      
      if password.blank?
        errors << "Password cannot be blank"
        return errors
      end
      
      errors << "Password must be at least 8 characters long" if password.length < 8
      errors << "Password must contain at least one uppercase letter" unless password.match?(/[A-Z]/)
      errors << "Password must contain at least one lowercase letter" unless password.match?(/[a-z]/)
      errors << "Password must contain at least one number" unless password.match?(/\d/)
      errors << "Password must contain at least one special character" unless password.match?(/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/)
      
      errors
    end
  end
end

