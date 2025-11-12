require 'rails_helper'

RSpec.describe PincodeServiceability, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:pincode) }
    it { should validate_uniqueness_of(:pincode) }
  end

  describe 'scopes' do
    describe '.serviceable' do
      it 'returns serviceable pincodes' do
        serviceable = create(:pincode_serviceability, is_serviceable: true)
        non_serviceable = create(:pincode_serviceability, is_serviceable: false)
        expect(PincodeServiceability.serviceable).to include(serviceable)
        expect(PincodeServiceability.serviceable).not_to include(non_serviceable)
      end
    end
  end

  describe 'class methods' do
    describe '.serviceable?' do
      it 'returns true for serviceable pincode' do
        create(:pincode_serviceability, pincode: '110001', is_serviceable: true)
        expect(PincodeServiceability.serviceable?('110001')).to be true
      end
    end
  end

  describe 'instance methods' do
    let(:pincode) { create(:pincode_serviceability, standard_delivery_days: 5, express_delivery_days: 2) }

    describe '#delivery_days' do
      it 'returns standard delivery days' do
        expect(pincode.delivery_days('standard')).to eq(5)
      end

      it 'returns express delivery days' do
        expect(pincode.delivery_days('express')).to eq(2)
      end
    end
  end
end





