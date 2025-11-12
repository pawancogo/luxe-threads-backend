require 'rails_helper'

RSpec.describe SearchSuggestion, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:query) }
    it { should validate_presence_of(:suggestion_type) }
  end

  describe 'enums' do
    it { should define_enum_for(:suggestion_type).with_values(
      product: 'product',
      category: 'category',
      brand: 'brand',
      trending: 'trending'
    ).backed_by_column_of_type(:string) }
  end

  describe 'scopes' do
    describe '.popular' do
      it 'orders by search_count desc' do
        low = create(:search_suggestion, search_count: 5)
        high = create(:search_suggestion, search_count: 100)
        expect(SearchSuggestion.popular.first).to eq(high)
      end
    end
  end

  describe 'instance methods' do
    let(:suggestion) { create(:search_suggestion, search_count: 10, click_count: 5) }

    describe '#increment_search!' do
      it 'increments search count' do
        expect { suggestion.increment_search! }.to change { suggestion.search_count }.by(1)
      end
    end

    describe '#increment_click!' do
      it 'increments click count' do
        expect { suggestion.increment_click! }.to change { suggestion.click_count }.by(1)
      end
    end
  end
end





