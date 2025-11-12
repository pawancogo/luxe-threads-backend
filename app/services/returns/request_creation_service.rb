# frozen_string_literal: true

# Service for creating return requests
module Returns
  class RequestCreationService < BaseService
    attr_reader :return_request

    def initialize(user, order, return_request_params, items_params)
      super()
      @user = user
      @order = order
      @return_request_params = return_request_params
      @items_params = items_params || []
    end

    def call
      validate_order!
      create_return_request
      create_return_items
      generate_return_id
      set_result(@return_request.reload)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate_order!
      unless @order
        add_error('Order is required')
        raise StandardError, 'Order not found'
      end

      unless @order.user_id == @user.id
        add_error('Order does not belong to user')
        raise StandardError, 'Unauthorized'
      end
    end

    def create_return_request
      @return_request = @user.return_requests.build(@return_request_params)
      @return_request.order = @order
      @return_request.status = 'requested'
      
      unless @return_request.save
        add_errors(@return_request.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @return_request
      end
    end

    def create_return_items
      return if @items_params.empty?

      @items_params.each do |item_params|
        return_item = @return_request.return_items.build(
          order_item_id: item_params[:order_item_id],
          quantity: item_params[:quantity],
          reason: item_params[:reason]
        )
        
        # Attach media if provided
        if item_params[:media].present?
          item_params[:media].each do |media_params|
            return_item.return_media.build(
              media_url: media_params[:file_key],
              media_type: media_params[:media_type] || 'image'
            )
          end
        end
        
        return_item.save!
      end
    end

    def generate_return_id
      @return_request.generate_return_id if @return_request.return_id.blank?
      @return_request.save!
    end
  end
end

