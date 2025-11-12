require 'rails_helper'

RSpec.describe UserCreationService, type: :service do
  describe '#call' do
    let(:valid_params) do
      {
        email: 'test@example.com',
        password: 'password123',
        password_confirmation: 'password123',
        first_name: 'John',
        last_name: 'Doe',
        phone_number: '1234567890',
        role: 'customer'
      }
    end

    context 'with valid parameters' do
      it 'creates a user successfully' do
        service = UserCreationService.new(valid_params)
        
        expect {
          service.call
        }.to change(User, :count).by(1)
        
        expect(service.success?).to be true
        expect(service.user).to be_persisted
        expect(service.user.email).to eq('test@example.com')
      end

      it 'creates associated resources' do
        service = UserCreationService.new(valid_params)
        service.call
        
        user = service.user
        expect(user.cart).to be_present
        expect(user.wishlist).to be_present
      end

      it 'creates email verification record' do
        service = UserCreationService.new(valid_params)
        service.call
        
        user = service.user
        expect(user.email_verifications).to be_present
      end
    end

    context 'with invalid parameters' do
      it 'returns errors for duplicate email' do
        create(:user, email: 'existing@example.com')
        invalid_params = valid_params.merge(email: 'existing@example.com')
        
        service = UserCreationService.new(invalid_params)
        service.call
        
        expect(service.success?).to be false
        expect(service.errors).to be_present
      end

      it 'returns errors for missing required fields' do
        invalid_params = valid_params.except(:email)
        
        service = UserCreationService.new(invalid_params)
        service.call
        
        expect(service.success?).to be false
        expect(service.errors).to be_present
      end
    end

    context 'with supplier role' do
      it 'creates supplier user' do
        supplier_params = valid_params.merge(
          role: 'supplier',
          company_name: 'Test Company',
          gst_number: '27AABCU9603R1ZX'
        )
        
        service = UserCreationService.new(supplier_params)
        service.call
        
        expect(service.success?).to be true
        expect(service.user.role).to eq('supplier')
      end
    end
  end
end





