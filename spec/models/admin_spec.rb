require 'rails_helper'

RSpec.describe Admin, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:phone_number) }
    it { should validate_presence_of(:role) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_uniqueness_of(:phone_number) }
  end

  describe 'associations' do
    it { should have_many(:admin_activities).dependent(:destroy) }
    it { should have_many(:admin_role_assignments).dependent(:destroy) }
    it { should have_many(:rbac_roles).through(:admin_role_assignments) }
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(
      super_admin: 'super_admin',
      product_admin: 'product_admin',
      order_admin: 'order_admin',
      user_admin: 'user_admin',
      supplier_admin: 'supplier_admin'
    ).backed_by_column_of_type(:string) }
  end

  describe 'scopes' do
    describe '.active' do
      it 'returns active admins' do
        active_admin = create(:admin, is_active: true, is_blocked: false)
        inactive_admin = create(:admin, is_active: false)
        
        expect(Admin.active).to include(active_admin)
        expect(Admin.active).not_to include(inactive_admin)
      end
    end
  end

  describe 'role methods' do
    let(:admin) { create(:admin) }

    it 'has super_admin? method' do
      admin.role = 'super_admin'
      expect(admin.super_admin?).to be true
    end

    it 'has product_admin? method' do
      admin.role = 'product_admin'
      expect(admin.product_admin?).to be true
    end

    it 'has order_admin? method' do
      admin.role = 'order_admin'
      expect(admin.order_admin?).to be true
    end
  end

  describe 'permission methods' do
    let(:super_admin) { create(:admin, role: 'super_admin') }
    let(:product_admin) { create(:admin, role: 'product_admin') }
    let(:order_admin) { create(:admin, role: 'order_admin') }

    describe '#can_manage_products?' do
      it 'returns true for super_admin' do
        expect(super_admin.can_manage_products?).to be true
      end

      it 'returns true for product_admin' do
        expect(product_admin.can_manage_products?).to be true
      end

      it 'returns false for order_admin' do
        expect(order_admin.can_manage_products?).to be false
      end
    end

    describe '#can_manage_orders?' do
      it 'returns true for super_admin' do
        expect(super_admin.can_manage_orders?).to be true
      end

      it 'returns true for order_admin' do
        expect(order_admin.can_manage_orders?).to be true
      end

      it 'returns false for product_admin' do
        expect(product_admin.can_manage_orders?).to be false
      end
    end
  end

  describe 'instance methods' do
    let(:admin) { create(:admin, first_name: 'John', last_name: 'Doe') }

    describe '#full_name' do
      it 'returns full name' do
        expect(admin.full_name).to eq('John Doe')
      end
    end

    describe '#block!' do
      it 'blocks admin' do
        admin.block!
        expect(admin.is_blocked).to be true
        expect(admin.is_active).to be false
      end
    end

    describe '#unblock!' do
      it 'unblocks admin' do
        admin.update(is_blocked: true, is_active: false)
        admin.unblock!
        expect(admin.is_blocked).to be false
        expect(admin.is_active).to be true
      end
    end

    describe '#update_last_login!' do
      it 'updates last login timestamp' do
        expect { admin.update_last_login! }.to change { admin.last_login_at }
      end
    end

    describe '#permissions_hash' do
      it 'returns parsed permissions' do
        admin.update(permissions: '{"products": {"create": true}}')
        expect(admin.permissions_hash).to eq({ 'products' => { 'create' => true } })
      end

      it 'returns empty hash for blank permissions' do
        admin.update(permissions: nil)
        expect(admin.permissions_hash).to eq({})
      end
    end
  end

  describe 'password methods' do
    let(:admin) { create(:admin) }

    describe '#authenticate' do
      it 'authenticates with correct password' do
        admin.password = 'password123'
        admin.save!
        expect(admin.authenticate('password123')).to be_truthy
      end

      it 'fails with incorrect password' do
        admin.password = 'password123'
        admin.save!
        expect(admin.authenticate('wrongpassword')).to be_falsey
      end
    end
  end

  describe 'callbacks' do
    it 'sends verification email after create' do
      admin = build(:admin, role: 'product_admin')
      expect {
        admin.save!
      }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
    end

    it 'does not send verification email for super_admin' do
      admin = build(:admin, role: 'super_admin')
      expect {
        admin.save!
      }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
    end
  end
end





