class Api::V1::ReviewsController < ApplicationController
  skip_before_action :authenticate_request, only: [:index]
  before_action :set_product, only: [:index, :create]

  # GET /api/v1/products/:product_id/reviews
  def index
    @reviews = @product.reviews.includes(:user).order(created_at: :desc)
    render_success(format_collection_data(@reviews), 'Reviews retrieved successfully')
  end

  # POST /api/v1/products/:product_id/reviews
  def create
    # Check if user has purchased this product
    has_purchased = current_user.orders.joins(:order_items)
                                .where(order_items: { product_variant_id: @product.product_variants.pluck(:id) })
                                .exists?
    
    @review = @product.reviews.build(review_params)
    @review.user = current_user
    @review.verified_purchase = has_purchased
    
    if @review.save
      render_created(format_model_data(@review), 'Review created successfully')
    else
      render_validation_errors(@review.errors.full_messages, 'Review creation failed')
    end
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  rescue ActiveRecord::RecordNotFound
    render_not_found('Product not found')
  end

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end
