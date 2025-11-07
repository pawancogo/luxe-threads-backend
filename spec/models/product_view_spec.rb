# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductView, type: :model do
  describe 'associations' do
    it { should belong_to(:product) }
    it { should belong_to(:user).optional }
    it { should belong_to(:product_variant).optional }
  end

  describe 'validations' do
    it { should validate_presence_of(:product_id) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      view = build(:product_view)
      expect(view).to be_valid
    end

    it 'creates view with user' do
      user = create(:user)
      view = create(:product_view, :with_user, user: user)
      expect(view.user).to eq(user)
    end

    it 'creates view with variant' do
      product = create(:product)
      variant = create(:product_variant, product: product)
      view = create(:product_view, product: product, :with_variant, product_variant: variant)
      expect(view.product_variant).to eq(variant)
    end
  end

  describe 'anonymous views' do
    it 'allows nil user for anonymous views' do
      view = build(:product_view, user: nil, session_id: 'test_session')
      expect(view).to be_valid
    end
  end
end

