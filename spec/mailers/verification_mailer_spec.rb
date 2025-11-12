require 'rails_helper'

RSpec.describe VerificationMailer, type: :mailer do
  let(:user) { create(:user, email: 'user@example.com') }

  describe '#verification_email' do
    let(:mail) { VerificationMailer.verification_email(user, '123456', 'user') }

    it 'renders the headers' do
      expect(mail.subject).to include('Verify')
      expect(mail.to).to eq(['user@example.com'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to include('123456')
    end
  end

  describe '#password_reset_email' do
    let(:mail) { VerificationMailer.password_reset_email(user, 'temp123', 'user') }

    it 'renders the headers' do
      expect(mail.subject).to include('Password Reset')
      expect(mail.to).to eq(['user@example.com'])
    end
  end
end





