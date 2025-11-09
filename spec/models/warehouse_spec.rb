require 'rails_helper'

RSpec.describe Warehouse, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:code) }
    it { should validate_presence_of(:address) }
    it { should validate_uniqueness_of(:code).scoped_to(:supplier_profile_id) }
  end

  describe 'associations' do
    it { should belong_to(:supplier_profile) }
    it { should have_many(:warehouse_inventory).dependent(:destroy) }
  end

  describe 'scopes' do
    describe '.active' do
      it 'returns active warehouses' do
        active = create(:warehouse, is_active: true)
        inactive = create(:warehouse, is_active: false)
        expect(Warehouse.active).to include(active)
        expect(Warehouse.active).not_to include(inactive)
      end
    end

    describe '.primary' do
      it 'returns primary warehouse' do
        primary = create(:warehouse, is_primary: true)
        non_primary = create(:warehouse, is_primary: false)
        expect(Warehouse.primary).to include(primary)
        expect(Warehouse.primary).not_to include(non_primary)
      end
    end
  end

  describe 'callbacks' do
    it 'ensures only one primary warehouse per supplier' do
      supplier = create(:supplier_profile)
      warehouse1 = create(:warehouse, supplier_profile: supplier, is_primary: true)
      warehouse2 = create(:warehouse, supplier_profile: supplier, is_primary: true)
      
      warehouse2.reload
      expect(warehouse1.reload.is_primary).to be false
      expect(warehouse2.is_primary).to be true
    end
  end
end

