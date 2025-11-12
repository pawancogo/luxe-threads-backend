require 'rails_helper'

RSpec.describe SupplierDocument, type: :model do
  describe 'associations' do
    it { should belong_to(:supplier_profile) }
  end

  describe 'validations' do
    it { should validate_presence_of(:document_type) }
    it { should validate_presence_of(:document_url) }
  end

  describe 'enums' do
    it { should define_enum_for(:document_type).with_values(gst_certificate: 'gst_certificate', pan_card: 'pan_card', bank_statement: 'bank_statement', address_proof: 'address_proof', other: 'other') }
    it { should define_enum_for(:verification_status).with_values(pending: 'pending', verified: 'verified', rejected: 'rejected') }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:supplier_document)).to be_valid
    end
  end
end





