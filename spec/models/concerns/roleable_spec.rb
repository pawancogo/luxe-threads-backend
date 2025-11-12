require 'rails_helper'

RSpec.describe Roleable, type: :concern do
  let(:test_model_class) do
    Class.new(ActiveRecord::Base) do
      self.table_name = 'users'
      include Roleable
    end
  end

  describe '#premium?' do
    it 'returns false by default' do
      instance = test_model_class.new
      expect(instance.premium?).to be false
    end
  end

  describe '#vip?' do
    it 'returns false by default' do
      instance = test_model_class.new
      expect(instance.vip?).to be false
    end
  end
end





