require 'rails_helper'

RSpec.describe ReturnMedia, type: :model do
  describe 'associations' do
    it { should belong_to(:return_item) }
  end

  describe 'validations' do
    it { should validate_presence_of(:media_type) }
    it { should validate_presence_of(:media_url) }
  end

  describe 'enums' do
    it { should define_enum_for(:media_type).with_values(image: 'image', video: 'video', document: 'document') }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:return_media)).to be_valid
    end
  end
end
