require 'rails_helper'

RSpec.describe AttributeType, type: :model do
  describe 'validations' do
    # No validations defined in the model
  end

  describe 'associations' do
    it { should have_many(:attribute_values).dependent(:destroy) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      attribute_type = build(:attribute_type)
      expect(attribute_type).to be_valid
    end
  end
end
