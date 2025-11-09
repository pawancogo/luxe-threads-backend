require 'rails_helper'

RSpec.describe Version, type: :model do
  describe 'scopes' do
    let(:user) { create(:user) }
    let(:admin) { create(:admin) }
    let(:product) { create(:product) }

    before do
      PaperTrail.request.whodunnit = "User:#{user.id}"
      product.update(name: 'Updated Name')
    end

    it 'filters by user' do
      versions = described_class.by_user(user.id)
      expect(versions).to be_present
    end

    it 'filters by admin' do
      PaperTrail.request.whodunnit = "Admin:#{admin.id}"
      product.update(name: 'Another Name')
      
      versions = described_class.by_admin(admin.id)
      expect(versions).to be_present
    end

    it 'filters by model' do
      versions = described_class.for_model(Product)
      expect(versions).to be_present
    end

    it 'filters by event' do
      versions = described_class.by_event('update')
      expect(versions).to be_present
    end
  end

  describe '#user_type' do
    it 'identifies admin type' do
      version = create(:version, whodunnit: 'Admin:1')
      expect(version.user_type).to eq('Admin')
    end

    it 'identifies user type' do
      version = create(:version, whodunnit: 'User:1')
      expect(version.user_type).to eq('User')
    end
  end

  describe '#user_id' do
    it 'extracts user ID from whodunnit' do
      version = create(:version, whodunnit: 'User:123')
      expect(version.user_id).to eq('123')
    end
  end
end

