require 'rails_helper'

RSpec.describe BulkDeletionService, type: :service do
  let(:service) { BulkDeletionService.new(User) }

  describe '#delete' do
    context 'with valid IDs' do
      it 'deletes multiple records' do
        users = create_list(:user, 3)
        user_ids = users.map(&:id)
        
        result = service.delete(user_ids)
        
        expect(service.success?).to be true
        expect(result[:deleted_count]).to eq(3)
        expect(User.where(id: user_ids)).to be_empty
      end
    end

    context 'with invalid IDs' do
      it 'handles non-existent IDs gracefully' do
        result = service.delete([99999, 99998])
        
        expect(service.success?).to be false
        expect(result[:deleted_count]).to eq(0)
      end
    end

    context 'with empty array' do
      it 'returns error' do
        expect {
          service.delete([])
        }.to raise_error(ArgumentError)
      end
    end
  end
end

