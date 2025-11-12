require 'rails_helper'

RSpec.describe AuditService, type: :service do
  describe '.set_current_user' do
    it 'sets whodunnit for admin user' do
      admin = create(:admin)
      AuditService.set_current_user(admin)
      
      expect(PaperTrail.request.whodunnit).to eq("Admin:#{admin.id}")
    end

    it 'sets whodunnit for regular user' do
      user = create(:user)
      AuditService.set_current_user(user)
      
      expect(PaperTrail.request.whodunnit).to eq("User:#{user.id}")
    end

    it 'sets whodunnit for supplier user' do
      supplier = create(:user, :supplier)
      AuditService.set_current_user(supplier)
      
      expect(PaperTrail.request.whodunnit).to eq("Supplier:#{supplier.id}")
    end
  end

  describe '.set_metadata' do
    it 'sets controller info from request' do
      request = double('request',
        remote_ip: '127.0.0.1',
        user_agent: 'Test Agent',
        request_id: 'test-123',
        controller_class: double(name: 'TestController'),
        action_name: 'index',
        params: { id: 1 }
      )
      
      AuditService.set_metadata(request)
      
      expect(PaperTrail.request.controller_info).to have_key(:ip_address)
      expect(PaperTrail.request.controller_info[:ip_address]).to eq('127.0.0.1')
    end
  end

  describe '.audit_trail_for' do
    it 'returns versions for model' do
      product = create(:product)
      product.update(name: 'Updated Name')
      
      trail = AuditService.audit_trail_for(product)
      
      expect(trail).to be_present
    end
  end
end





