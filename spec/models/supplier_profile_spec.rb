require 'rails_helper'

RSpec.describe SupplierProfile, type: :model do
  subject { build(:supplier_profile) }
  
  describe 'validations' do
    it { should validate_presence_of(:company_name) }
    it { should validate_presence_of(:gst_number) }
    it { should validate_uniqueness_of(:gst_number) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:products).dependent(:destroy) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      supplier_profile = build(:supplier_profile)
      expect(supplier_profile).to be_valid
    end
  end
end