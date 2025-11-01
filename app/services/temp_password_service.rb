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
  
  # Generic method that works for any model with temp_password_digest field
  def self.generate_for(model)
    temp_password = generate
    # Hash the temporary password with argon2
    temp_password_digest = PasswordHashingService.hash_password(temp_password)
    
    model.update!(
      temp_password_digest: temp_password_digest,
      temp_password_expires_at: EXPIRY_HOURS.hours.from_now,
      password_reset_required: true
    )
    temp_password
  end
  
  # Generic authentication method
  def self.authenticate_temp_password(model, temp_password)
    return false if model.temp_password_digest.blank?
    return false if model.temp_password_expires_at.blank? || model.temp_password_expires_at < Time.current
    
    PasswordHashingService.verify_password(temp_password, model.temp_password_digest)
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
      password_reset_required: false
    )
  end
end
