require 'rails_helper'

RSpec.describe Brand, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      brand = build(:brand)
      expect(brand).to be_valid
    end
  end
end
