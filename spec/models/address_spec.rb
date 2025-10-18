require 'rails_helper'

RSpec.describe Address, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:full_name) }
    it { should validate_presence_of(:phone_number) }
    it { should validate_presence_of(:line1) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:state) }
    it { should validate_presence_of(:postal_code) }
    it { should validate_presence_of(:country) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:shipping_orders).class_name('Order').with_foreign_key('shipping_address_id') }
    it { should have_many(:billing_orders).class_name('Order').with_foreign_key('billing_address_id') }
  end

  describe 'enums' do
    it { should define_enum_for(:address_type).with_values(shipping: 'shipping', billing: 'billing').backed_by_column_of_type(:string) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      address = build(:address)
      expect(address).to be_valid
    end
  end
end