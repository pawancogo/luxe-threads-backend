require 'rails_helper'

RSpec.describe Setting, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:key) }
    it { should validate_uniqueness_of(:key) }
    it { should validate_inclusion_of(:value_type).in_array(%w[string integer float boolean json]) }
    it { should validate_inclusion_of(:category).in_array(%w[general payment shipping email feature_flags]) }
  end

  describe 'scopes' do
    describe '.by_category' do
      it 'filters by category' do
        general = create(:setting, category: 'general')
        payment = create(:setting, category: 'payment')
        expect(Setting.by_category('general')).to include(general)
        expect(Setting.by_category('general')).not_to include(payment)
      end
    end
  end

  describe 'class methods' do
    describe '.get' do
      it 'returns setting value' do
        create(:setting, key: 'test_key', value: 'test_value', value_type: 'string')
        expect(Setting.get('test_key')).to eq('test_value')
      end

      it 'returns default when not found' do
        expect(Setting.get('nonexistent', 'default')).to eq('default')
      end
    end

    describe '.set' do
      it 'creates or updates setting' do
        setting = Setting.set('new_key', 'new_value')
        expect(setting.persisted?).to be true
        expect(setting.value).to eq('new_value')
      end
    end
  end

  describe 'instance methods' do
    describe '#cast_value' do
      it 'casts integer value' do
        setting = create(:setting, value: '100', value_type: 'integer')
        expect(setting.cast_value).to eq(100)
      end

      it 'casts boolean value' do
        setting = create(:setting, value: 'true', value_type: 'boolean')
        expect(setting.cast_value).to be true
      end

      it 'casts json value' do
        setting = create(:setting, value: '{"key": "value"}', value_type: 'json')
        expect(setting.cast_value).to have_key('key')
      end
    end
  end
end

