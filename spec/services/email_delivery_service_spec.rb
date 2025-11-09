require 'rails_helper'

RSpec.describe EmailDeliveryService, type: :service do
  describe '.deliver' do
    it 'delivers email successfully' do
      mail = double('mail', deliver_now: true)
      mailer = double('mailer', call: mail)
      
      result = EmailDeliveryService.deliver(mailer)
      
      expect(result).to be true
    end

    it 'handles delivery errors gracefully' do
      mailer = -> { raise StandardError, 'Delivery failed' }
      
      result = EmailDeliveryService.deliver(mailer)
      
      expect(result).to be false
    end
  end
end

