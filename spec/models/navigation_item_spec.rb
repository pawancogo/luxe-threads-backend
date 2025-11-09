require 'rails_helper'

RSpec.describe NavigationItem, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:key) }
    it { should validate_presence_of(:label) }
    it { should validate_presence_of(:path_method) }
    it { should validate_presence_of(:display_order) }
    it { should validate_uniqueness_of(:key) }
  end

  describe 'scopes' do
    describe '.active' do
      it 'returns active items' do
        active = create(:navigation_item, is_active: true)
        inactive = create(:navigation_item, is_active: false)
        expect(NavigationItem.active).to include(active)
        expect(NavigationItem.active).not_to include(inactive)
      end
    end

    describe '.ordered' do
      it 'orders by section and display_order' do
        item1 = create(:navigation_item, section: 'main', display_order: 2)
        item2 = create(:navigation_item, section: 'main', display_order: 1)
        expect(NavigationItem.ordered.first).to eq(item2)
      end
    end
  end

  describe 'instance methods' do
    let(:item) { create(:navigation_item) }

    describe '#can_view_item?' do
      it 'returns true for always visible items' do
        item.update(always_visible: true)
        user = create(:user)
        expect(item.can_view_item?(user)).to be true
      end
    end
  end
end

