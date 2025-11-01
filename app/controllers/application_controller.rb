class ApplicationController < ActionController::API
  include JsonWebToken
  include ApiResponder
  include Pundit::Authorization

  before_action :authenticate_request
  
  # Override Pundit's user method to use current_user
  def pundit_user
    current_user
  end

  private

  def authenticate_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    begin
      @decoded = jwt_decode(header)
      @current_user = User.find(@decoded[:user_id])
    rescue ActiveRecord::RecordNotFound => e
      render_unauthorized(e.message)
    rescue JWT::DecodeError => e
      render_unauthorized(e.message)
    end
  end

  attr_reader :current_user
end
