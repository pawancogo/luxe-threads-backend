# frozen_string_literal: true

# Service for tracking product views
module Products
  class ViewTrackingService < BaseService
    attr_reader :product_view

    def initialize(product, user_id: nil, product_variant_id: nil, session_id: nil,
                   ip_address: nil, user_agent: nil, referrer_url: nil, source: 'direct')
      super()
      @product = product
      @user_id = user_id
      @product_variant_id = product_variant_id
      @session_id = session_id
      @ip_address = ip_address
      @user_agent = user_agent
      @referrer_url = referrer_url
      @source = source
    end

    def call
      track_view
      set_result(@product_view)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def track_view
      @product_view = ProductView.track_view(
        @product.id,
        user_id: @user_id,
        product_variant_id: @product_variant_id,
        session_id: @session_id,
        ip_address: @ip_address,
        user_agent: @user_agent,
        referrer_url: @referrer_url,
        source: @source
      )
    end
  end
end

