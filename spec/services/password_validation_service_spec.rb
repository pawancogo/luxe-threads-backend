require 'rails_helper'

RSpec.describe PasswordValidationService, type: :service do
  describe '.valid?' do
    it 'validates strong password' do
      expect(PasswordValidationService.valid?('Password123!')).to be true
    end

    it 'rejects blank password' do
      expect(PasswordValidationService.valid?('')).to be false
      expect(PasswordValidationService.valid?(nil)).to be false
    end

    it 'rejects short password' do
      expect(PasswordValidationService.valid?('Pass1!')).to be false
    end

    it 'rejects password without uppercase' do
      expect(PasswordValidationService.valid?('password123!')).to be false
    end

    it 'rejects password without lowercase' do
      expect(PasswordValidationService.valid?('PASSWORD123!')).to be false
    end

    it 'rejects password without number' do
      expect(PasswordValidationService.valid?('Password!')).to be false
    end

    it 'rejects password without special character' do
      expect(PasswordValidationService.valid?('Password123')).to be false
    end
  end

  describe '.errors' do
    it 'returns empty array for valid password' do
      expect(PasswordValidationService.errors('Password123!')).to be_empty
    end

    it 'returns errors for invalid password' do
      errors = PasswordValidationService.errors('weak')
      expect(errors).not_to be_empty
      expect(errors).to include('Password must be at least 8 characters long')
    end
  end
end





