require 'rails_helper'

RSpec.describe WarehouseInventory, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:stock_quantity) }
    it { should validate_presence_of(:reserved_quantity) }
    it { should validate_uniqueness_of(:warehouse_id).scoped_to(:product_variant_id) }
    it { should validate_numericality_of(:stock_quantity).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:reserved_quantity).is_greater_than_or_equal_to(0) }
  end

  describe 'associations' do
    it { should belong_to(:warehouse) }
    it { should belong_to(:product_variant) }
  end

  describe 'instance methods' do
    let(:inventory) { create(:warehouse_inventory, stock_quantity: 100, reserved_quantity: 20) }

    describe '#available_quantity' do
      it 'calculates available quantity' do
        expect(inventory.available_quantity).to eq(80)
      end
    end

    describe '#in_stock?' do
      it 'returns true when stock available' do
        expect(inventory.in_stock?).to be true
      end

      it 'returns false when out of stock' do
        inventory.update(stock_quantity: 0)
        expect(inventory.in_stock?).to be false
      end
    end

    describe '#low_stock?' do
      it 'returns true when below threshold' do
        inventory.update(stock_quantity: 5, reserved_quantity: 0)
        expect(inventory.low_stock?).to be true
      end
    end
  end
end

