require 'rails_helper'

RSpec.describe JsonWebToken, type: :controller do
  controller(ActionController::Base) do
    include JsonWebToken

    def test_jwt_encode
      render json: { token: jwt_encode({ user_id: 1 }) }
    end

    def test_jwt_decode
      token = params[:token]
      decoded = jwt_decode(token)
      render json: { decoded: decoded }
    end
  end

  describe '#jwt_encode' do
    it 'encodes a payload into a JWT token' do
      routes.draw { get 'test_jwt_encode' => 'anonymous#test_jwt_encode' }

      get :test_jwt_encode

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to have_key('token')
    end

    it 'includes expiration time' do
      routes.draw { get 'test_jwt_encode' => 'anonymous#test_jwt_encode' }

      get :test_jwt_encode

      token = JSON.parse(response.body)['token']
      decoded = JWT.decode(token, Rails.application.secret_key_base)[0]
      expect(decoded).to have_key('exp')
    end
  end

  describe '#jwt_decode' do
    let(:payload) { { user_id: 123, exp: 7.days.from_now.to_i } }
    let(:token) { JWT.encode(payload, Rails.application.secret_key_base) }

    it 'decodes a valid JWT token' do
      routes.draw { get 'test_jwt_decode' => 'anonymous#test_jwt_decode' }

      get :test_jwt_decode, params: { token: token }

      expect(response).to have_http_status(:ok)
      decoded = JSON.parse(response.body)['decoded']
      expect(decoded['user_id']).to eq(123)
    end

    it 'returns HashWithIndifferentAccess' do
      routes.draw { get 'test_jwt_decode' => 'anonymous#test_jwt_decode' }

      get :test_jwt_decode, params: { token: token }

      decoded = JSON.parse(response.body)['decoded']
      expect(decoded).to be_a(Hash)
      expect(decoded.with_indifferent_access).to be_a(HashWithIndifferentAccess)
    end
  end
end