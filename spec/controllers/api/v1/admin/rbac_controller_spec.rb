require 'rails_helper'

RSpec.describe Api::V1::Admin::RbacController, type: :controller do
  let(:admin) { create(:admin, role: 'super_admin') }
  let(:auth_headers) { { 'Authorization' => "Bearer #{jwt_encode({ admin_id: admin.id })}" } }

  before do
    request.headers.merge!(auth_headers)
  end

  describe 'GET #roles' do
    it 'returns all RBAC roles' do
      create_list(:rbac_role, 3)
      
      get :roles
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
    end
  end

  describe 'GET #permissions' do
    it 'returns all RBAC permissions' do
      create_list(:rbac_permission, 3)
      
      get :permissions
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
    end
  end

  describe 'POST #assign_role' do
    let(:target_admin) { create(:admin) }
    let(:rbac_role) { create(:rbac_role) }

    it 'assigns role to admin' do
      expect {
        post :assign_role, params: {
          admin_id: target_admin.id,
          role_id: rbac_role.id
        }
      }.to change(AdminRoleAssignment, :count).by(1)
      
      expect(response).to have_http_status(:created)
    end
  end

  def jwt_encode(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end

