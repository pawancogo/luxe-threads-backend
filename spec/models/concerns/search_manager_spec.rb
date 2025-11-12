require 'rails_helper'

RSpec.describe SearchManager, type: :concern do
  let(:test_model_class) do
    Class.new(ActiveRecord::Base) do
      self.table_name = 'products'
      extend SearchManager
    end
  end

  describe '.search_manager' do
    it 'configures search fields' do
      test_model_class.search_manager on: [:name, :description]
      expect(test_model_class.on).to eq([:name, :description])
    end

    it 'raises error without :on option' do
      expect {
        test_model_class.search_manager
      }.to raise_error(ArgumentError)
    end
  end

  describe '._search' do
    before do
      test_model_class.search_manager on: [:name, :description], aggs_on: [[:category, :category_id]]
    end

    it 'searches by text' do
      product = create(:product, name: 'Test Product')
      result = test_model_class._search({ search: 'Test' })
      expect(result).to include(product)
    end

    it 'applies filters' do
      category = create(:category)
      product = create(:product, category: category)
      result = test_model_class._search({ category: category.id })
      expect(result).to include(product)
    end
  end

  describe '.aggs_count' do
    it 'returns aggregation count' do
      create_list(:product, 3, category: create(:category))
      test_model_class.search_manager aggs_on: [[:category, :category_id]]
      result = test_model_class.aggs_count
      expect(result).to be_a(Hash)
    end
  end
end





