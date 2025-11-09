require 'rails_helper'

RSpec.describe Inventoriable, type: :concern do
  let(:test_model) do
    product_variant = create(:product_variant, stock_quantity: 100, reserved_quantity: 20, low_stock_threshold: 10)
    product_variant.extend(Inventoriable)
    product_variant
  end

  describe '#inventory_object' do
    it 'returns Inventory value object' do
      inventory = test_model.inventory_object
      expect(inventory).to be_a(Inventory)
      expect(inventory.stock_quantity).to eq(100)
      expect(inventory.reserved_quantity).to eq(20)
    end
  end

  describe '#available_quantity' do
    it 'returns available quantity' do
      expect(test_model.available_quantity).to eq(80)
    end
  end

  describe '#in_stock?' do
    it 'returns true when stock available' do
      expect(test_model.in_stock?).to be true
    end

    it 'returns false when out of stock' do
      test_model.update(stock_quantity: 0)
      expect(test_model.in_stock?).to be false
    end
  end

  describe '#out_of_stock?' do
    it 'returns false when stock available' do
      expect(test_model.out_of_stock?).to be false
    end

    it 'returns true when out of stock' do
      test_model.update(stock_quantity: 0)
      expect(test_model.out_of_stock?).to be true
    end
  end

  describe '#low_stock?' do
    it 'returns true when stock is low' do
      test_model.update(stock_quantity: 5)
      expect(test_model.low_stock?).to be true
    end

    it 'returns false when stock is sufficient' do
      expect(test_model.low_stock?).to be false
    end
  end

  describe '#can_fulfill?' do
    it 'returns true when can fulfill quantity' do
      expect(test_model.can_fulfill?(50)).to be true
    end

    it 'returns false when cannot fulfill quantity' do
      expect(test_model.can_fulfill?(150)).to be false
    end
  end

  describe '#stock_status' do
    it 'returns stock status' do
      expect(test_model.stock_status).to be_a(String)
    end
  end

  describe '#stock_status_message' do
    it 'returns stock status message' do
      expect(test_model.stock_status_message).to be_a(String)
    end
  end
end

