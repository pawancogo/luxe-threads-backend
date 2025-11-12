require 'rails_helper'

RSpec.describe Api::V1::Admin::EmailTemplatesController, type: :controller do
  let(:admin) { create(:admin, role: 'super_admin') }
  let(:auth_headers) { { 'Authorization' => "Bearer #{jwt_encode({ admin_id: admin.id })}" } }

  before do
    request.headers.merge!(auth_headers)
  end

  describe 'GET #index' do
    it 'returns all email templates' do
      create_list(:email_template, 3)
      
      get :index
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
    end
  end

  describe 'GET #show' do
    let(:template) { create(:email_template) }

    it 'returns template details' do
      get :show, params: { template_type: template.template_type }
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['template_type']).to eq(template.template_type)
    end
  end

  describe 'PUT #update' do
    let(:template) { create(:email_template, subject: 'Old Subject') }

    it 'updates email template' do
      put :update, params: {
        template_type: template.template_type,
        email_template: { subject: 'New Subject' }
      }
      
      expect(response).to have_http_status(:ok)
      template.reload
      expect(template.subject).to eq('New Subject')
    end
  end

  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end





