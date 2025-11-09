require 'rails_helper'

RSpec.describe PasswordHashingService, type: :service do
  describe '.hash_password' do
    it 'hashes password with Argon2' do
      password = 'test_password123'
      hash = PasswordHashingService.hash_password(password)
      
      expect(hash).to be_present
      expect(hash).to start_with('$argon2')
    end
  end

  describe '.verify_password' do
    let(:password) { 'test_password123' }
    let(:hash) { PasswordHashingService.hash_password(password) }

    it 'verifies correct password' do
      expect(PasswordHashingService.verify_password(password, hash)).to be true
    end

    it 'rejects incorrect password' do
      expect(PasswordHashingService.verify_password('wrong_password', hash)).to be false
    end

    it 'returns false for blank hash' do
      expect(PasswordHashingService.verify_password(password, nil)).to be false
    end
  end

  describe '.needs_rehash?' do
    it 'returns false for current hash format' do
      hash = PasswordHashingService.hash_password('test')
      expect(PasswordHashingService.needs_rehash?(hash)).to be false
    end
  end
end

