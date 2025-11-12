require 'rails_helper'

RSpec.describe Rbac::PermissionCacheService, type: :service do
  let(:admin) { create(:admin) }
  let(:permission_slug) { 'products:view' }

  describe '.get_admin_permission' do
    it 'returns nil when cache is empty' do
      expect(described_class.get_admin_permission(admin.id, permission_slug)).to be_nil
    end

    it 'returns cached permission value' do
      described_class.set_admin_permission(admin.id, permission_slug, true)
      expect(described_class.get_admin_permission(admin.id, permission_slug)).to be true
    end
  end

  describe '.set_admin_permission' do
    it 'caches permission value' do
      described_class.set_admin_permission(admin.id, permission_slug, true)
      expect(Rails.cache.read("admin:#{admin.id}:permission:#{permission_slug}")).to be true
    end
  end

  describe '.clear_admin_cache' do
    it 'clears all admin permissions from cache' do
      described_class.set_admin_permission(admin.id, permission_slug, true)
      described_class.clear_admin_cache(admin.id)
      
      expect(described_class.get_admin_permission(admin.id, permission_slug)).to be_nil
    end
  end

  describe '.get_admin_all_permissions' do
    it 'returns nil when cache is empty' do
      expect(described_class.get_admin_all_permissions(admin.id)).to be_nil
    end

    it 'returns cached permissions array' do
      permissions = ['products:view', 'products:create']
      described_class.set_admin_all_permissions(admin.id, permissions)
      
      expect(described_class.get_admin_all_permissions(admin.id)).to eq(permissions)
    end
  end
end





