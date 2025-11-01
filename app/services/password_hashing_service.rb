class PasswordHashingService
  # Argon2 configuration for secure password hashing
  # m_cost must be a power of 2 and at least 8 (256 KB), typically 16 (4MB) or 32 (128MB)
  # Using default Argon2 settings which are production-ready
  ARGON2_CONFIG = {
    t_cost: 2,      # Time cost (number of iterations) - 2 is sufficient for most cases
    m_cost: 16,     # Memory cost (2^16 = 64KB, but Argon2 internally converts this)
    parallelism: 1  # Parallelism factor
  }.freeze

  # Hash a password using Argon2
  def self.hash_password(password)
    # Use Argon2 with default secure settings
    Argon2::Password.create(password)
  end

  # Verify a password against a hash
  def self.verify_password(password, hash)
    return false if hash.blank? || password.blank?
    
    # Check if hash is a valid Argon2 hash format
    # Argon2 hashes typically start with $argon2id$ or $argon2i$ or $argon2d$
    # Bcrypt hashes start with $2a$, $2b$, or $2y$
    if hash.start_with?('$2a$') || hash.start_with?('$2b$') || hash.start_with?('$2y$')
      # Old bcrypt hash - needs to be rehashed with Argon2
      Rails.logger.warn "Legacy bcrypt hash detected. Hash needs to be rehashed with Argon2."
      return false
    end
    
    unless hash.start_with?('$argon2')
      # Unknown hash format
      Rails.logger.warn "Unknown hash format detected. Hash needs to be rehashed."
      return false
    end
    
    begin
      Argon2::Password.verify_password(password, hash)
    rescue Argon2::ArgonHashFail => e
      Rails.logger.error "Argon2 verification failed: #{e.message}"
      false
    end
  end

  # Check if a password needs to be rehashed (for future upgrades)
  def self.needs_rehash?(hash)
    # For now, always return false since we're using consistent config
    # In the future, you could check if the hash uses older parameters
    false
  end
end

