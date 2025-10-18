require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:phone_number) }
    it { should validate_presence_of(:role) }
    
    it { should validate_uniqueness_of(:email) }
  end

  describe 'associations' do
    it { should have_many(:orders) }
    it { should have_one(:supplier_profile) }
    it { should have_many(:addresses) }
    it { should have_many(:reviews) }
    it { should have_one(:wishlist) }
    it { should have_one(:cart) }
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(customer: 'customer', supplier: 'supplier', super_admin: 'super_admin', product_admin: 'product_admin', order_admin: 'order_admin').backed_by_column_of_type(:string) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'creates a supplier user' do
      user = create(:user, role: 'supplier')
      expect(user.role).to eq('supplier')
    end

    it 'creates an admin user' do
      user = create(:user, role: 'super_admin')
      expect(user.role).to eq('super_admin')
    end
  end

  describe 'callbacks' do
    it 'creates a cart after user creation' do
      user = build(:user)
      expect { user.save! }.to change(Cart, :count).by(1)
      expect(user.cart).to be_present
    end

    it 'creates a wishlist after user creation' do
      user = build(:user)
      expect { user.save! }.to change(Wishlist, :count).by(1)
      expect(user.wishlist).to be_present
    end
  end

  describe 'methods' do
    let(:user) { create(:user) }

    describe '#admin?' do
      it 'returns true for super_admin' do
        user.role = 'super_admin'
        expect(user.admin?).to be true
      end

      it 'returns true for product_admin' do
        user.role = 'product_admin'
        expect(user.admin?).to be true
      end

      it 'returns true for order_admin' do
        user.role = 'order_admin'
        expect(user.admin?).to be true
      end

      it 'returns false for customer' do
        user.role = 'customer'
        expect(user.admin?).to be false
      end

      it 'returns false for supplier' do
        user.role = 'supplier'
        expect(user.admin?).to be false
      end
    end

    describe '#supplier?' do
      it 'returns true for supplier role' do
        user.role = 'supplier'
        expect(user.supplier?).to be true
      end

      it 'returns false for other roles' do
        user.role = 'customer'
        expect(user.supplier?).to be false
      end
    end

    describe 'role methods' do
      it 'has customer? method' do
        user.role = 'customer'
        expect(user.customer?).to be true
      end

      it 'has super_admin? method' do
        user.role = 'super_admin'
        expect(user.super_admin?).to be true
      end

      it 'has product_admin? method' do
        user.role = 'product_admin'
        expect(user.product_admin?).to be true
      end

      it 'has order_admin? method' do
        user.role = 'order_admin'
        expect(user.order_admin?).to be true
      end
    end
  end
end
