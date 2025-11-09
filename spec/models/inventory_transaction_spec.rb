require 'rails_helper'

RSpec.describe InventoryTransaction, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:transaction_type) }
    it { should validate_presence_of(:quantity) }
    it { should validate_presence_of(:balance_after) }
    it { should validate_uniqueness_of(:transaction_id) }
    it { should validate_numericality_of(:quantity).other_than(0) }
    it { should validate_numericality_of(:balance_after).is_greater_than_or_equal_to(0) }
  end

  describe 'associations' do
    it { should belong_to(:product_variant) }
    it { should belong_to(:supplier_profile) }
    it { should belong_to(:performed_by).class_name('User').optional }
  end

  describe 'enums' do
    it { should define_enum_for(:transaction_type).with_values(
      purchase: 'purchase',
      sale: 'sale',
      return: 'return',
      adjustment: 'adjustment',
      transfer: 'transfer',
      damage: 'damage',
      expiry: 'expiry'
    ).backed_by_column_of_type(:string) }
  end

  describe 'callbacks' do
    it 'generates transaction_id before validation' do
      transaction = build(:inventory_transaction, transaction_id: nil)
      transaction.valid?
      expect(transaction.transaction_id).to be_present
      expect(transaction.transaction_id).to start_with('INV-')
    end
  end
end

