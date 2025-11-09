# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SystemConfiguration, type: :model do
  describe 'associations' do
    it { should belong_to(:created_by).optional }
  end

  describe 'validations' do
    it { should validate_presence_of(:key) }
    it { should validate_uniqueness_of(:key).case_insensitive }
    it { should validate_inclusion_of(:value_type).in_array(%w[string integer float boolean json]) }
    it { should validate_presence_of(:category) }
  end

  describe 'scopes' do
    let!(:active_config) { SystemConfiguration.create!(key: 'active_key', value: 'active_value', is_active: true) }
    let!(:inactive_config) { SystemConfiguration.create!(key: 'inactive_key', value: 'inactive_value', is_active: false) }
    let!(:payment_config) { SystemConfiguration.create!(key: 'payment_key', value: 'payment_value', category: 'payment') }

    describe '.active' do
      it 'returns only active configurations' do
        expect(SystemConfiguration.active).to include(active_config)
        expect(SystemConfiguration.active).not_to include(inactive_config)
      end
    end

    describe '.by_category' do
      it 'returns configurations by category' do
        expect(SystemConfiguration.by_category('payment')).to include(payment_config)
        expect(SystemConfiguration.by_category('payment')).not_to include(active_config)
      end
    end

    describe '.by_key' do
      it 'returns configuration by key' do
        expect(SystemConfiguration.by_key('active_key')).to include(active_config)
      end
    end

    describe '.by_creator' do
      let(:admin) { Admin.create!(email: 'admin@test.com', first_name: 'Admin', last_name: 'User', role: 'super_admin', password: 'Password123!', phone_number: '1234567890') }
      let!(:admin_config) { SystemConfiguration.create!(key: 'admin_key', value: 'admin_value', created_by: admin) }

      it 'returns configurations by creator' do
        expect(SystemConfiguration.by_creator(admin)).to include(admin_config)
        expect(SystemConfiguration.by_creator(admin)).not_to include(active_config)
      end
    end

    describe '.by_creator_type' do
      let(:admin) { Admin.create!(email: 'admin@test.com', first_name: 'Admin', last_name: 'User', role: 'super_admin', password: 'Password123!', phone_number: '1234567890') }
      let!(:admin_config) { SystemConfiguration.create!(key: 'admin_key', value: 'admin_value', created_by: admin) }

      it 'returns configurations by creator type' do
        expect(SystemConfiguration.by_creator_type('Admin')).to include(admin_config)
      end
    end
  end

  describe '.get' do
    context 'when configuration exists' do
      let!(:config) { SystemConfiguration.create!(key: 'test_key', value: '123', value_type: 'integer') }

      it 'returns the casted value' do
        expect(SystemConfiguration.get('test_key')).to eq(123)
      end

      it 'returns default when key not found' do
        expect(SystemConfiguration.get('non_existent', 'default')).to eq('default')
      end
    end

    context 'when configuration is inactive' do
      let!(:config) { SystemConfiguration.create!(key: 'inactive_key', value: 'value', is_active: false) }

      it 'returns default value' do
        expect(SystemConfiguration.get('inactive_key', 'default')).to eq('default')
      end
    end
  end

  describe '.set' do
    let(:admin) { Admin.create!(email: 'admin@test.com', first_name: 'Admin', last_name: 'User', role: 'super_admin', password: 'Password123!', phone_number: '1234567890') }

    it 'creates a new configuration' do
      config = SystemConfiguration.set('new_key', 'new_value')
      expect(config).to be_persisted
      expect(config.key).to eq('new_key')
      expect(config.value).to eq('new_value')
    end

    it 'updates existing configuration' do
      SystemConfiguration.create!(key: 'existing_key', value: 'old_value')
      config = SystemConfiguration.set('existing_key', 'new_value')
      expect(config.value).to eq('new_value')
    end

    it 'accepts options' do
      config = SystemConfiguration.set('typed_key', '123', value_type: 'integer', category: 'payment', description: 'Test config')
      expect(config.value_type).to eq('integer')
      expect(config.category).to eq('payment')
      expect(config.description).to eq('Test config')
    end

    it 'accepts created_by option' do
      config = SystemConfiguration.set('admin_key', 'admin_value', created_by: admin)
      expect(config.created_by).to eq(admin)
      expect(config.created_by_type).to eq('Admin')
    end
  end

  describe '.all_as_hash' do
    before do
      SystemConfiguration.create!(key: 'key1', value: 'value1', category: 'general')
      SystemConfiguration.create!(key: 'key2', value: 'value2', category: 'payment')
      SystemConfiguration.create!(key: 'key3', value: 'value3', category: 'payment', is_active: false)
    end

    it 'returns all active configurations as hash' do
      hash = SystemConfiguration.all_as_hash
      expect(hash).to include('key1' => 'value1', 'key2' => 'value2')
      expect(hash).not_to include('key3')
    end

    it 'filters by category' do
      hash = SystemConfiguration.all_as_hash(category: 'payment')
      expect(hash).to include('key2' => 'value2')
      expect(hash).not_to include('key1')
    end
  end

  describe '.bulk_set' do
    it 'creates multiple configurations' do
      configs = SystemConfiguration.bulk_set(
        { 'key1' => 'value1', 'key2' => 'value2' },
        category: 'test'
      )
      expect(configs.length).to eq(2)
      expect(SystemConfiguration.get('key1')).to eq('value1')
      expect(SystemConfiguration.get('key2')).to eq('value2')
    end

    it 'accepts hash values with options' do
      SystemConfiguration.bulk_set(
        {
          'key1' => { value: 'value1', value_type: 'integer' },
          'key2' => { value: 'value2', category: 'payment' }
        }
      )
      expect(SystemConfiguration.get('key1')).to eq(0) # 'value1'.to_i
      expect(SystemConfiguration.find_by(key: 'key2').category).to eq('payment')
    end
  end

  describe '#cast_value' do
    it 'casts integer values' do
      config = SystemConfiguration.new(key: 'int_key', value: '123', value_type: 'integer')
      expect(config.cast_value).to eq(123)
    end

    it 'casts float values' do
      config = SystemConfiguration.new(key: 'float_key', value: '123.45', value_type: 'float')
      expect(config.cast_value).to eq(123.45)
    end

    it 'casts boolean values' do
      config = SystemConfiguration.new(key: 'bool_key', value: 'true', value_type: 'boolean')
      expect(config.cast_value).to eq(true)
    end

    it 'casts json values' do
      config = SystemConfiguration.new(key: 'json_key', value: '{"key":"value"}', value_type: 'json')
      expect(config.cast_value).to eq({ 'key' => 'value' })
    end

    it 'returns string values as-is' do
      config = SystemConfiguration.new(key: 'string_key', value: 'test', value_type: 'string')
      expect(config.cast_value).to eq('test')
    end
  end

  describe '#normalize_value' do
    it 'normalizes integer values' do
      config = SystemConfiguration.new(key: 'int_key', value: '123', value_type: 'integer')
      config.valid?
      expect(config.value).to eq('123')
    end

    it 'normalizes boolean values' do
      config = SystemConfiguration.new(key: 'bool_key', value: 'yes', value_type: 'boolean')
      config.valid?
      expect(config.value).to eq('true')
    end

    it 'normalizes json values' do
      config = SystemConfiguration.new(key: 'json_key', value: { key: 'value' }, value_type: 'json')
      config.valid?
      expect(config.value).to eq('{"key":"value"}')
    end
  end

  describe '#activate! and #deactivate!' do
    let(:config) { SystemConfiguration.create!(key: 'test_key', value: 'value', is_active: true) }

    it 'deactivates configuration' do
      config.deactivate!
      expect(config.reload.is_active).to be false
    end

    it 'activates configuration' do
      config.update!(is_active: false)
      config.activate!
      expect(config.reload.is_active).to be true
    end
  end

  describe '#creator_name' do
    let(:admin) { Admin.create!(email: 'admin@test.com', first_name: 'John', last_name: 'Doe', role: 'super_admin', password: 'Password123!', phone_number: '1234567890') }

    context 'when created_by is present' do
      let(:config) { SystemConfiguration.create!(key: 'test_key', value: 'value', created_by: admin) }

      it 'returns creator full name' do
        expect(config.creator_name).to eq('John Doe')
      end
    end

    context 'when created_by is nil' do
      let(:config) { SystemConfiguration.create!(key: 'test_key', value: 'value') }

      it 'returns System' do
        expect(config.creator_name).to eq('System')
      end
    end
  end

  describe '#created_by_admin? and #created_by_user?' do
    let(:admin) { Admin.create!(email: 'admin@test.com', first_name: 'Admin', last_name: 'User', role: 'super_admin', password: 'Password123!', phone_number: '1234567890') }
    let(:admin_config) { SystemConfiguration.create!(key: 'admin_key', value: 'value', created_by: admin) }
    let(:system_config) { SystemConfiguration.create!(key: 'system_key', value: 'value') }

    it 'returns true for admin-created config' do
      expect(admin_config.created_by_admin?).to be true
      expect(admin_config.created_by_user?).to be false
    end

    it 'returns false for system-created config' do
      expect(system_config.created_by_admin?).to be false
      expect(system_config.created_by_user?).to be false
    end
  end

  describe '.by_creator_type_and_role' do
    let(:super_admin) { Admin.create!(email: 'super@test.com', first_name: 'Super', last_name: 'Admin', role: 'super_admin', password: 'Password123!', phone_number: '1234567890') }
    let(:product_admin) { Admin.create!(email: 'product@test.com', first_name: 'Product', last_name: 'Admin', role: 'product_admin', password: 'Password123!', phone_number: '1234567891') }
    let!(:super_config) { SystemConfiguration.create!(key: 'super_key', value: 'value', created_by: super_admin) }
    let!(:product_config) { SystemConfiguration.create!(key: 'product_key', value: 'value', created_by: product_admin) }

    it 'filters by creator type and role' do
      super_configs = SystemConfiguration.by_creator_type_and_role('Admin', role: 'super_admin')
      expect(super_configs).to include(super_config)
      expect(super_configs).not_to include(product_config)
    end
  end
end

