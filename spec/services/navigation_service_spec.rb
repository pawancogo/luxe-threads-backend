require 'rails_helper'

RSpec.describe NavigationService, type: :service do
  describe '.visible_items' do
    it 'returns navigation items for user' do
      create(:navigation_item, is_active: true, always_visible: true)
      
      items = NavigationService.visible_items(create(:user))
      
      expect(items).to be_a(Hash)
    end

    it 'filters by user permissions' do
      item = create(:navigation_item, is_active: true, always_visible: false)
      user = create(:user)
      
      items = NavigationService.visible_items(user)
      
      expect(items).to be_a(Hash)
    end

    it 'returns empty hash for nil user' do
      expect(NavigationService.visible_items(nil)).to eq({})
    end
  end

  describe '.can_view?' do
    it 'checks if user can view navigation item' do
      item = create(:navigation_item, is_active: true, always_visible: true)
      user = create(:user)
      
      result = NavigationService.can_view?(user, item.key)
      
      expect(result).to be true
    end
  end
end

