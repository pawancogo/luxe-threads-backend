require 'rails_helper'

RSpec.describe TempPasswordService, type: :service do
  let(:user) { create(:user) }

  describe '.generate' do
    it 'generates a temporary password' do
      password = TempPasswordService.generate
      
      expect(password).to be_present
      expect(password.length).to eq(12)
    end

    it 'generates unique passwords' do
      password1 = TempPasswordService.generate
      password2 = TempPasswordService.generate
      
      expect(password1).not_to eq(password2)
    end
  end

  describe '.generate_for' do
    it 'generates and stores temp password for model' do
      temp_password = TempPasswordService.generate_for(user)
      
      expect(temp_password).to be_present
      expect(user.temp_password_digest).to be_present
      expect(user.temp_password_expires_at).to be_present
      expect(user.password_reset_required).to be true
    end
  end

  describe '.authenticate_temp_password' do
    it 'authenticates with correct temp password' do
      temp_password = TempPasswordService.generate_for(user)
      
      expect(TempPasswordService.authenticate_temp_password(user, temp_password)).to be true
    end

    it 'rejects incorrect temp password' do
      TempPasswordService.generate_for(user)
      
      expect(TempPasswordService.authenticate_temp_password(user, 'wrong_password')).to be false
    end

    it 'rejects expired temp password' do
      temp_password = TempPasswordService.generate_for(user)
      user.update(temp_password_expires_at: 1.hour.ago)
      
      expect(TempPasswordService.authenticate_temp_password(user, temp_password)).to be false
    end
  end

  describe '.clear_temp_password' do
    it 'clears temp password fields' do
      TempPasswordService.generate_for(user)
      TempPasswordService.clear_temp_password(user)
      
      expect(user.temp_password_digest).to be_nil
      expect(user.temp_password_expires_at).to be_nil
      expect(user.password_reset_required).to be false
    end
  end
end





