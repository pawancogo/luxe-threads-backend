require 'rails_helper'

RSpec.describe ShippingMethod, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:code) }
    it { should validate_uniqueness_of(:code) }
  end

  describe 'associations' do
    it { should have_many(:shipments).dependent(:restrict_with_error) }
  end

  describe 'scopes' do
    describe '.active' do
      it 'returns active shipping methods' do
        active = create(:shipping_method, is_active: true)
        inactive = create(:shipping_method, is_active: false)
        
        expect(ShippingMethod.active).to include(active)
        expect(ShippingMethod.active).not_to include(inactive)
      end
    end

    describe '.cod_available' do
      it 'returns COD available methods' do
        cod_available = create(:shipping_method, is_cod_available: true)
        cod_not_available = create(:shipping_method, is_cod_available: false)
        
        expect(ShippingMethod.cod_available).to include(cod_available)
        expect(ShippingMethod.cod_available).not_to include(cod_not_available)
      end
    end
  end

  describe 'instance methods' do
    let(:shipping_method) { create(:shipping_method) }

    describe '#available_pincodes_list' do
      it 'returns parsed pincodes' do
        shipping_method.update(available_pincodes: '["110001", "110002"]')
        expect(shipping_method.available_pincodes_list).to eq(['110001', '110002'])
      end
    end
  end
end





