require 'rails_helper'

RSpec.describe Api::V1::SearchController, type: :controller do
  let(:user) { create(:user) }
  let(:product) { create(:product, name: 'Test Product') }

  before do
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:authenticate_request)
  end

  describe 'inheritance' do
    it 'inherits from ApplicationController' do
      expect(Api::V1::SearchController.superclass).to eq(ApplicationController)
    end
  end

  describe 'before_actions' do
    it 'has authenticate_request before_action' do
      expect(Api::V1::SearchController._process_action_callbacks.map(&:filter)).to include(:authenticate_request)
    end
  end

  describe 'GET #search' do
    it 'raises error since search is not implemented' do
      expect { get :search, params: { query: 'Test' } }.to raise_error(NoMethodError)
    end
  end

  describe 'private methods' do
    describe '#range_filter' do
      it 'creates range filter with min and max values' do
        result = controller.send(:range_filter, '10', '100')
        expect(result).to eq({ gte: 10.0, lte: 100.0 })
      end

      it 'creates range filter with only min value' do
        result = controller.send(:range_filter, '10', nil)
        expect(result).to eq({ gte: 10.0 })
      end

      it 'creates range filter with only max value' do
        result = controller.send(:range_filter, nil, '100')
        expect(result).to eq({ lte: 100.0 })
      end

      it 'creates empty range filter with no values' do
        result = controller.send(:range_filter, nil, nil)
        expect(result).to eq({})
      end

      it 'handles empty string values' do
        result = controller.send(:range_filter, '', '')
        expect(result).to eq({})
      end

      it 'converts string values to float' do
        result = controller.send(:range_filter, '10.5', '99.9')
        expect(result).to eq({ gte: 10.5, lte: 99.9 })
      end
    end
  end
end