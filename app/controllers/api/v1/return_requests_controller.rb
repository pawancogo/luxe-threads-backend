class Api::V1::ReturnRequestsController < ApplicationController
  # GET /api/v1/my-returns or /api/v1/return_requests
  def index
    @return_requests = current_user.return_requests.includes(
      order: [:order_items],
      return_items: [:order_item, :return_media]
    ).order(created_at: :desc)
    
    render_success(format_return_requests_data(@return_requests), 'Return requests retrieved successfully')
  end

  # GET /api/v1/return_requests/:id
  def show
    @return_request = current_user.return_requests.includes(
      order: [:order_items, :user],
      return_items: [:order_item, :return_media]
    ).find(params[:id])
    
    render_success(format_return_request_detail_data(@return_request), 'Return request retrieved successfully')
  rescue ActiveRecord::RecordNotFound
    render_not_found('Return request not found')
  end

  # POST /api/v1/return_requests
  def create
    @return_request = current_user.return_requests.build(return_request_params)
    @return_request.status = 'requested'
    
    if @return_request.save
      # Create return items
      if params[:items].present?
        params[:items].each do |item_params|
          return_item = @return_request.return_items.build(
            order_item_id: item_params[:order_item_id],
            quantity: item_params[:quantity],
            reason: item_params[:reason]
          )
          
          # Attach media if provided
          if item_params[:media].present?
            item_params[:media].each do |media_params|
              return_item.return_media.build(
                media_url: media_params[:file_key], # Assuming file_key is S3 key or URL
                media_type: media_params[:media_type] || 'image'
              )
            end
          end
          
          return_item.save!
        end
      end
      
      render_created(format_return_request_detail_data(@return_request.reload), 'Return request created successfully')
    else
      render_validation_errors(@return_request.errors.full_messages, 'Return request creation failed')
    end
  rescue ActiveRecord::RecordInvalid => e
    render_validation_errors(e.record.errors.full_messages, 'Return request creation failed')
  end

  private

  def return_request_params
    params.require(:return_request).permit(:order_id, :resolution_type)
  end

  def format_return_requests_data(return_requests)
    return_requests.map do |return_request|
      {
        id: return_request.id,
        order_id: return_request.order_id,
        status: return_request.status,
        resolution_type: return_request.resolution_type,
        created_at: return_request.created_at.iso8601,
        item_count: return_request.return_items.sum(:quantity)
      }
    end
  end

  def format_return_request_detail_data(return_request)
    {
      id: return_request.id,
      order_id: return_request.order_id,
      status: return_request.status,
      resolution_type: return_request.resolution_type,
      created_at: return_request.created_at.iso8601,
      order: {
        id: return_request.order.id,
        order_number: return_request.order.id.to_s.rjust(8, '0'),
        total_amount: return_request.order.total_amount
      },
      items: return_request.return_items.map do |item|
        {
          id: item.id,
          order_item: {
            id: item.order_item.id,
            product_name: item.order_item.product_variant.product.name,
            sku: item.order_item.product_variant.sku,
            quantity: item.order_item.quantity
          },
          quantity: item.quantity,
          reason: item.reason,
          media: item.return_media.map do |media|
            {
              id: media.id,
              url: media.media_url,
              type: media.media_type
            }
          end
        }
      end
    }
  end
end
