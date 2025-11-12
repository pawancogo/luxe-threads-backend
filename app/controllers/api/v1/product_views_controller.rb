# frozen_string_literal: true

class Api::V1::ProductViewsController < ApplicationController
  skip_before_action :authenticate_request, only: [:track]
  
  # Phase 6: Feature flag check
  before_action :require_product_views_feature!, only: [:track]
  
  private
  
  def require_product_views_feature!
    unless feature_enabled?(:product_views_tracking)
      render_error('Product views tracking is not enabled', nil, :service_unavailable)
    end
  end
  
  # POST /api/v1/products/:product_id/views
  def track
    product = Product.find(params[:product_id])
    
    service = Products::ViewTrackingService.new(
      product,
      user_id: current_user&.id,
      product_variant_id: params[:product_variant_id],
      session_id: request.headers['X-Session-Id'] || session.id,
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      referrer_url: request.referer,
      source: params[:source] || 'direct'
    )
    service.call
    
    if service.success?
      render_success({ id: service.product_view.id }, 'Product view tracked successfully')
    else
      render_error(service.errors.first || 'Failed to track product view', :unprocessable_entity)
    end
  rescue ActiveRecord::RecordNotFound
    render_not_found('Product not found')
  end
end

