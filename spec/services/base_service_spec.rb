require 'rails_helper'

RSpec.describe BaseService, type: :service do
  # Create a test service class that inherits from BaseService
  let(:test_service_class) do
    Class.new(BaseService) do
      def call
        set_result(true)
        self
      end
    end
  end

  let(:failing_service_class) do
    Class.new(BaseService) do
      def call
        add_error('Test error')
        set_last_error(StandardError.new('Test error'))
        self
      end
    end
  end

  describe '#initialize' do
    it 'initializes with empty errors array' do
      service = test_service_class.new
      expect(service.errors).to eq([])
      expect(service.last_error).to be_nil
    end
  end

  describe '#call' do
    it 'raises NotImplementedError if not implemented' do
      service = BaseService.new
      expect { service.call }.to raise_error(NotImplementedError)
    end

    it 'can be implemented by subclasses' do
      service = test_service_class.new
      result = service.call
      expect(result).to be_a(BaseService)
    end
  end

  describe '#success?' do
    it 'returns true when no errors' do
      service = test_service_class.new
      service.call
      expect(service.success?).to be true
    end

    it 'returns false when errors exist' do
      service = failing_service_class.new
      service.call
      expect(service.success?).to be false
    end
  end

  describe '#failure?' do
    it 'returns false when successful' do
      service = test_service_class.new
      service.call
      expect(service.failure?).to be false
    end

    it 'returns true when failed' do
      service = failing_service_class.new
      service.call
      expect(service.failure?).to be true
    end
  end

  describe '#add_error' do
    it 'adds error message' do
      service = BaseService.new
      service.send(:add_error, 'Test error')
      expect(service.errors).to include('Test error')
    end

    it 'does not add duplicate errors' do
      service = BaseService.new
      service.send(:add_error, 'Test error')
      service.send(:add_error, 'Test error')
      expect(service.errors.count).to eq(1)
    end
  end

  describe '#add_errors' do
    it 'adds multiple error messages' do
      service = BaseService.new
      service.send(:add_errors, ['Error 1', 'Error 2'])
      expect(service.errors).to include('Error 1', 'Error 2')
    end
  end

  describe '#with_transaction' do
    it 'executes block in transaction' do
      service = BaseService.new
      expect(ActiveRecord::Base).to receive(:transaction).and_yield
      service.send(:with_transaction) { true }
    end

    it 'handles errors in transaction' do
      service = BaseService.new
      expect {
        service.send(:with_transaction) { raise StandardError, 'Test error' }
      }.to raise_error(StandardError)
    end
  end
end

