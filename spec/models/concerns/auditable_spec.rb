require 'rails_helper'

RSpec.describe Auditable, type: :concern do
  let(:test_model_class) do
    Class.new(ActiveRecord::Base) do
      self.table_name = 'users'
      include Auditable
    end
  end

  describe 'included behavior' do
    it 'adds paper_trail functionality' do
      expect(test_model_class).to respond_to(:has_paper_trail)
    end

    it 'adds paranoid functionality' do
      expect(test_model_class).to respond_to(:acts_as_paranoid)
    end
  end

  describe '#audit_summary' do
    it 'delegates to AuditService' do
      instance = test_model_class.new
      expect(AuditService).to receive(:audit_summary).with(instance)
      instance.audit_summary
    end
  end

  describe '#audit_trail' do
    it 'delegates to AuditService' do
      instance = test_model_class.new
      expect(AuditService).to receive(:audit_trail_for).with(instance)
      instance.audit_trail
    end
  end
end





