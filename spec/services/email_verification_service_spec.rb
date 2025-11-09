require 'rails_helper'

RSpec.describe EmailVerificationService, type: :service do
  let(:user) { create(:user, email_verified: false) }
  let(:service) { EmailVerificationService.new(user) }

  describe '#send_verification_email' do
    it 'creates and sends verification email' do
      expect {
        service.send_verification_email
      }.to change(EmailVerification, :count).by(1)
    end

    it 'does not send if email already verified' do
      user.update(email_verified: true)
      
      expect {
        service.send_verification_email
      }.not_to change(EmailVerification, :count)
    end
  end

  describe '#verify_email_with_otp' do
    let(:verification) { create(:email_verification, verifiable: user, email: user.email) }

    it 'verifies email with correct OTP' do
      result = service.verify_email_with_otp(verification.otp)
      
      expect(result[:success]).to be true
      expect(user.reload.email_verified).to be true
    end

    it 'fails with incorrect OTP' do
      result = service.verify_email_with_otp('wrong_otp')
      
      expect(result[:success]).to be false
    end
  end

  describe '#verification_status' do
    it 'returns verified if email is verified' do
      user.update(email_verified: true)
      expect(service.verification_status).to eq('verified')
    end

    it 'returns pending if verification exists' do
      create(:email_verification, verifiable: user)
      expect(service.verification_status).to eq('pending')
    end
  end
end

