# frozen_string_literal: true

class Api::V1::ReviewsController < ApplicationController
  include EagerLoading
  
  skip_before_action :authenticate_request, only: [:index]
  before_action :set_product, only: [:index, :create]

  # GET /api/v1/products/:product_id/reviews
  def index
    base_scope = with_eager_loading(
      @product.reviews,
      additional_includes: review_includes
    )
    
    service = ReviewListingService.new(base_scope, params)
    service.call
    
    if service.success?
      serialized_reviews = service.reviews.map { |review| ReviewSerializer.new(review).as_json }
      render_success(serialized_reviews, 'Reviews retrieved successfully')
    else
      render_validation_errors(service.errors, 'Failed to retrieve reviews')
    end
  end

  # POST /api/v1/products/:product_id/reviews
  def create
    service = Reviews::CreationService.new(@product, current_user, review_params)
    service.call
    
    if service.success?
      render_created(
        ReviewSerializer.new(service.review).as_json,
        'Review created successfully'
      )
    else
      render_validation_errors(service.errors, 'Review creation failed')
    end
  end

  # POST /api/v1/products/:product_id/reviews/:id/vote
  def vote
    @review = @product.reviews.find(params[:id])
    
    service = Reviews::VoteService.new(@review, current_user, params[:is_helpful])
    service.call
    
    if service.success?
      render_success(
        ReviewSerializer.new(@review.reload).as_json,
        'Vote recorded successfully'
      )
    else
      render_validation_errors(service.errors, 'Vote failed')
    end
  end

  # PATCH /api/v1/admin/reviews/:id/moderate
  def admin_moderate
    authorize_admin!
    
    @review = with_eager_loading(
      Review.all,
      additional_includes: review_includes
    ).find(params[:id])
    
    moderation_params_data = params[:review] || {}
    
    service = Reviews::ModerationService.new(@review, moderation_params_data)
    service.call
    
    if service.success?
      render_success(
        ReviewSerializer.new(@review.reload).as_json,
        'Review moderated successfully'
      )
    else
      render_validation_errors(service.errors, 'Review moderation failed')
    end
  rescue ActiveRecord::RecordNotFound
    render_not_found('Review not found')
  end

  # PATCH /api/v1/supplier/reviews/:id/respond
  def supplier_respond
    authorize_supplier!
    ensure_supplier_profile!
    
    @review = with_eager_loading(
      Review.all,
      additional_includes: review_includes
    ).find(params[:id])
    
    supplier_response = params[:supplier_response]
    
    service = Reviews::SupplierResponseService.new(
      @review,
      current_user.supplier_profile,
      supplier_response
    )
    service.call
    
    if service.success?
      render_success(
        ReviewSerializer.new(@review.reload).as_json,
        'Response added successfully'
      )
    else
      render_validation_errors(service.errors, 'Response failed')
    end
  rescue ActiveRecord::RecordNotFound
    render_not_found('Review not found')
  end

  private

  def authorize_admin!
    render_unauthorized('Admin access required') unless current_user&.admin?
  end

  def authorize_supplier!
    render_unauthorized('Supplier access required') unless current_user&.supplier?
  end

  def ensure_supplier_profile!
    if current_user.supplier_profile.nil?
      render_validation_errors(
        ['Supplier profile not found. Please create a supplier profile first.'],
        'Supplier profile required'
      )
      return
    end
  end

  def set_product
    @product = with_eager_loading(
      Product.all,
      additional_includes: [:brand, :category, :supplier_profile]
    ).find(params[:product_id])
  rescue ActiveRecord::RecordNotFound
    render_not_found('Product not found')
  end

  def review_params
    # Phase 3: Include Phase 3 fields
    params.require(:review).permit(
      :rating,
      :comment,
      :title,
      :order_item_id,
      review_images: []
    )
  end

end
