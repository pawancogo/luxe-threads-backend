require "jwt"
module JsonWebToken
  extend ActiveSupport::Concern

  def jwt_encode(payload, exp: 7.days.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, Rails.application.secret_key_base)
  end

  def jwt_decode(token)
    decoded = JWT.decode(token, Rails.application.secret_key_base)[0]
    HashWithIndifferentAccess.new decoded
  end
end