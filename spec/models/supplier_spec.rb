require 'rails_helper'

RSpec.describe Supplier, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:phone_number) }
    it { should validate_presence_of(:role) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_uniqueness_of(:phone_number) }
  end

  describe 'associations' do
    it { should have_one(:supplier_profile).dependent(:destroy) }
    it { should have_many(:products).through(:supplier_profile) }
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(basic_supplier: 'basic_supplier', verified_supplier: 'verified_supplier', premium_supplier: 'premium_supplier', partner_supplier: 'partner_supplier') }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:supplier)).to be_valid
    end
  end

  describe '#verified?' do
    it 'returns true for verified suppliers' do
      supplier = create(:supplier, role: 'verified_supplier')
      expect(supplier.verified?).to be true
    end

    it 'returns false for basic suppliers' do
      supplier = create(:supplier, role: 'basic_supplier')
      expect(supplier.verified?).to be false
    end
  end

  describe '#full_name' do
    it 'returns full name' do
      supplier = create(:supplier, first_name: 'John', last_name: 'Doe')
      expect(supplier.full_name).to eq('John Doe')
    end
  end
end

