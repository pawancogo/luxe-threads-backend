# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvitationService, type: :service do
  let(:admin) { create(:admin, role: 'super_admin') }
  let(:supplier_owner) { create(:user, :supplier) }
  let(:supplier_profile) { create(:supplier_profile, owner: supplier_owner, user: supplier_owner) }
  
  describe '#send_admin_invitation' do
    context 'with valid data' do
      let(:invitee) { Admin.new(email: 'newadmin@example.com') }
      let(:service) { InvitationService.new(invitee, admin) }
      
      it 'creates admin with invitation fields' do
        expect(service.send_admin_invitation('product_admin')).to be true
        
        invitee.reload
        expect(invitee.role).to eq('product_admin')
        expect(invitee.invitation_status).to eq('pending')
        expect(invitee.invitation_token).to be_present
        expect(invitee.invited_by_id).to eq(admin.id)
        expect(invitee.is_active).to be false
      end
      
      it 'sends invitation email' do
        expect {
          service.send_admin_invitation('product_admin')
        }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
    
    context 'with invalid data' do
      let(:invitee) { Admin.new(email: '') }
      let(:service) { InvitationService.new(invitee, admin) }
      
      it 'returns false and sets errors' do
        expect(service.send_admin_invitation('product_admin')).to be false
        expect(service.errors).to be_present
      end
    end
  end
  
  describe '#send_supplier_invitation' do
    context 'parent supplier invitation' do
      let(:invitee) { User.new(email: 'newsupplier@example.com') }
      let(:service) { InvitationService.new(invitee, admin) }
      
      it 'creates user with invitation fields' do
        expect(service.send_supplier_invitation('supplier')).to be true
        
        invitee.reload
        expect(invitee.role).to eq('supplier')
        expect(invitee.invitation_role).to eq('supplier')
        expect(invitee.invitation_status).to eq('pending')
        expect(invitee.invitation_token).to be_present
        expect(invitee.invited_by_id).to eq(admin.id)
        expect(invitee.is_active).to be false
      end
      
      it 'does not create SupplierAccountUser' do
        service.send_supplier_invitation('supplier')
        expect(SupplierAccountUser.where(user_id: invitee.id)).to be_empty
      end
    end
    
    context 'child supplier invitation' do
      let(:invitee) { User.new(email: 'childsupplier@example.com') }
      let(:service) { InvitationService.new(invitee, admin) }
      let(:options) do
        {
          supplier_profile_id: supplier_profile.id,
          account_role: 'staff',
          permissions: {
            can_manage_products: true,
            can_manage_orders: false
          }
        }
      end
      
      it 'creates user and SupplierAccountUser' do
        expect(service.send_supplier_invitation('supplier', options)).to be true
        
        invitee.reload
        expect(invitee.role).to eq('supplier')
        expect(invitee.invitation_status).to eq('pending')
        
        account_user = SupplierAccountUser.find_by(user_id: invitee.id)
        expect(account_user).to be_present
        expect(account_user.supplier_profile_id).to eq(supplier_profile.id)
        expect(account_user.role).to eq('staff')
        expect(account_user.status).to eq('pending_invitation')
        expect(account_user.can_manage_products).to be true
        expect(account_user.can_manage_orders).to be false
      end
    end
  end
  
  describe '#accept_invitation' do
    let(:token) { SecureRandom.urlsafe_base64(32) }
    let(:params) do
      {
        token: token,
        first_name: 'John',
        last_name: 'Doe',
        phone_number: '+1234567890',
        password: 'password123',
        password_confirmation: 'password123'
      }
    end
    
    context 'parent supplier acceptance' do
      let(:invitee) do
        create(:user, :supplier, :pending_invitation,
          email: 'supplier@example.com',
          invitation_token: token,
          invitation_expires_at: 7.days.from_now
        )
      end
      let(:service) { InvitationService.new(invitee) }
      
      it 'activates account and marks invitation as accepted' do
        expect(service.accept_invitation(params)).to be true
        
        invitee.reload
        expect(invitee.first_name).to eq('John')
        expect(invitee.last_name).to eq('Doe')
        expect(invitee.is_active).to be true
        expect(invitee.invitation_status).to eq('accepted')
        expect(invitee.invitation_token).to be_nil
      end
      
      it 'creates supplier profile if provided' do
        params[:supplier_profile_attributes] = {
          company_name: 'Test Company',
          gst_number: 'GST123'
        }
        
        service.accept_invitation(params)
        
        invitee.reload
        profile = invitee.supplier_profile
        expect(profile).to be_present
        expect(profile.company_name).to eq('Test Company')
        expect(profile.verified).to be false # Needs admin approval
      end
    end
    
    context 'child supplier acceptance' do
      let(:invitee) do
        create(:user, :supplier, :pending_invitation,
          email: 'child@example.com',
          invitation_token: token,
          invitation_expires_at: 7.days.from_now
        )
      end
      let(:account_user) do
        create(:supplier_account_user, :pending,
          user: invitee,
          supplier_profile: supplier_profile,
          role: 'staff'
        )
      end
      let(:service) { InvitationService.new(invitee) }
      
      before { account_user }
      
      it 'activates account and SupplierAccountUser immediately' do
        expect(service.accept_invitation(params)).to be true
        
        invitee.reload
        expect(invitee.is_active).to be true
        expect(invitee.invitation_status).to eq('accepted')
        
        account_user.reload
        expect(account_user.status).to eq('active')
        expect(account_user.accepted_at).to be_present
      end
      
      it 'verifies supplier profile automatically' do
        supplier_profile.update(verified: false)
        
        service.accept_invitation(params)
        
        supplier_profile.reload
        expect(supplier_profile.verified).to be true
      end
    end
    
    context 'with expired invitation' do
      let(:invitee) do
        create(:user, :supplier, :pending_invitation,
          email: 'expired@example.com',
          invitation_token: token,
          invitation_expires_at: 1.day.ago
        )
      end
      let(:service) { InvitationService.new(invitee) }
      
      it 'returns false' do
        expect(service.accept_invitation(params)).to be false
        expect(service.errors).to be_present
      end
    end
  end
  
  describe '#resend_invitation' do
    let(:invitee) do
      create(:user, :supplier, :pending_invitation,
        email: 'resend@example.com',
        invitation_token: 'old_token',
        invitation_expires_at: 7.days.from_now
      )
    end
    let(:service) { InvitationService.new(invitee, admin) }
    
    it 'generates new token and sends email' do
      old_token = invitee.invitation_token
      
      expect(service.resend_invitation).to be true
      
      invitee.reload
      expect(invitee.invitation_token).not_to eq(old_token)
      expect(invitee.invitation_sent_at).to be_present
    end
  end
  
  describe '#check_if_child_supplier' do
    let(:invitee) { create(:user, role: 'supplier') }
    let(:service) { InvitationService.new(invitee) }
    
    context 'when has pending SupplierAccountUser' do
      before do
        create(:supplier_account_user,
          user: invitee,
          status: 'pending_invitation'
        )
      end
      
      it 'returns true' do
        expect(service.send(:check_if_child_supplier)).to be true
      end
    end
    
    context 'when no SupplierAccountUser' do
      it 'returns false' do
        expect(service.send(:check_if_child_supplier)).to be false
      end
    end
  end
end

