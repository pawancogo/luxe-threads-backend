require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:slug).allow_nil }
  end

  describe 'associations' do
    it { should belong_to(:parent).class_name('Category').optional }
    it { should have_many(:sub_categories).class_name('Category').with_foreign_key('parent_id').dependent(:destroy) }
    it { should have_many(:products).dependent(:nullify) }
  end

  describe 'scopes' do
    it 'filters root categories' do
      root = create(:category, parent_id: nil)
      child = create(:category, parent: root)
      
      expect(Category.root_categories).to include(root)
      expect(Category.root_categories).not_to include(child)
    end

    it 'filters active categories' do
      active = create(:category, active: true)
      inactive = create(:category, active: false)
      
      expect(Category.active).to include(active)
      expect(Category.active).not_to include(inactive)
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:category)).to be_valid
    end
  end

  describe '#path' do
    it 'returns category path' do
      parent = create(:category, name: 'Parent')
      child = create(:category, name: 'Child', parent: parent)
      
      expect(child.path).to include('Parent')
      expect(child.path).to include('Child')
    end
  end
end
