require 'rails_helper'

RSpec.describe ReturnMedia, type: :model do
  describe 'associations' do
    it { should belong_to(:return_item) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      return_media = build(:return_media)
      expect(return_media).to be_valid
    end
  end

  describe 'methods' do
    let(:return_media) { create(:return_media) }

    describe 'media_type methods' do
      it 'has image? method' do
        return_media.media_type = 'image'
        expect(return_media.image?).to be true
      end

      it 'has video? method' do
        return_media.media_type = 'video'
        expect(return_media.video?).to be true
      end
    end
  end
end