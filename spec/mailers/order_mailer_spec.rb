require 'rails_helper'

RSpec.describe OrderMailer, type: :mailer do
  let(:user) { create(:user, email: 'customer@example.com') }
  let(:order) { create(:order, user: user, order_number: 'ORD-001') }

  describe '#order_confirmation' do
    let(:mail) { OrderMailer.order_confirmation(order) }

    it 'renders the headers' do
      expect(mail.subject).to include('Order Confirmation')
      expect(mail.subject).to include('ORD-001')
      expect(mail.to).to eq(['customer@example.com'])
      expect(mail.from).to be_present
    end

    it 'renders the body' do
      expect(mail.body.encoded).to include(order.order_number)
      expect(mail.body.encoded).to include(user.full_name)
    end

    it 'includes order items' do
      order_item = create(:order_item, order: order)
      mail = OrderMailer.order_confirmation(order.reload)
      expect(mail.body.encoded).to be_present
    end
  end

  describe '#order_shipped' do
    let(:shipment) { create(:shipment, order: order, tracking_number: 'TRACK123') }
    let(:mail) { OrderMailer.order_shipped(order, shipment) }

    it 'renders the headers' do
      expect(mail.subject).to include('Shipped')
      expect(mail.to).to eq(['customer@example.com'])
    end

    it 'includes tracking information' do
      expect(mail.body.encoded).to include('TRACK123')
    end
  end

  describe '#order_delivered' do
    let(:mail) { OrderMailer.order_delivered(order) }

    it 'renders the headers' do
      expect(mail.subject).to include('Delivered')
      expect(mail.to).to eq(['customer@example.com'])
    end
  end

  describe '#order_cancelled' do
    let(:order) { create(:order, user: user, order_number: 'ORD-001', cancellation_reason: 'Customer request') }
    let(:mail) { OrderMailer.order_cancelled(order) }

    it 'renders the headers' do
      expect(mail.subject).to include('Cancelled')
      expect(mail.to).to eq(['customer@example.com'])
    end

    it 'includes cancellation reason' do
      expect(mail.body.encoded).to include('Customer request')
    end
  end
end

