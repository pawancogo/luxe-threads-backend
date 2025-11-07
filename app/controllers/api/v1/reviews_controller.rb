# frozen_string_literal: true

class Api::V1::ReviewsController < ApplicationController
  include EagerLoading
  
  skip_before_action :authenticate_request, only: [:index]
  before_action :set_product, only: [:index, :create]

  # GET /api/v1/products/:product_id/reviews
  def index
    @reviews = with_eager_loading(
      @product.reviews,
      additional_includes: review_includes
    )
    
    # Phase 3: Filter by moderation status
    @reviews = @reviews.where(moderation_status: params[:moderation_status]) if params[:moderation_status].present?
    @reviews = @reviews.where(is_featured: true) if params[:featured] == 'true'
    @reviews = @reviews.where(is_verified_purchase: true) if params[:verified] == 'true'
    
    @reviews = @reviews.order(created_at: :desc)
    render_success(format_collection_data(@reviews), 'Reviews retrieved successfully')
  end

  # POST /api/v1/products/:product_id/reviews
  def create
    # Phase 3: Check if user has purchased this product (for verified purchase)
    order_item = current_user.orders.joins(:order_items)
                             .where(order_items: { product_variant_id: @product.product_variants.pluck(:id) })
                             .order('orders.created_at DESC')
                             .first&.order_items&.find_by(product_variant_id: @product.product_variants.pluck(:id))
    
    @review = @product.reviews.build(review_params)
    @review.user = current_user
    @review.order_item = order_item
    @review.moderation_status = 'pending' # Phase 3: Default to pending moderation
    
    if @review.save
      render_created(format_review_data(@review), 'Review created successfully')
    else
      render_validation_errors(@review.errors.full_messages, 'Review creation failed')
    end
  end

  # POST /api/v1/products/:product_id/reviews/:id/vote
  def vote
    @review = @product.reviews.find(params[:id])
    @vote = @review.review_helpful_votes.find_or_initialize_by(user: current_user)
    @vote.is_helpful = params[:is_helpful] == 'true' || params[:is_helpful] == true
    
    if @vote.save
      @review.update_helpful_counts
      render_success(format_review_data(@review.reload), 'Vote recorded successfully')
    else
      render_validation_errors(@vote.errors.full_messages, 'Vote failed')
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
    
    update_hash = {}
    update_hash[:moderation_status] = moderation_params_data[:moderation_status] if moderation_params_data.key?(:moderation_status)
    update_hash[:is_featured] = moderation_params_data[:is_featured] if moderation_params_data.key?(:is_featured)
    update_hash[:moderation_notes] = moderation_params_data[:moderation_notes] if moderation_params_data.key?(:moderation_notes)
    
    if @review.update(update_hash)
      render_success(format_review_data(@review), 'Review moderated successfully')
    else
      render_validation_errors(@review.errors.full_messages, 'Review moderation failed')
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
    
    # Check if review is for a product from this supplier
    unless @review.product.supplier_profile_id == current_user.supplier_profile.id
      render_unauthorized('Not authorized to respond to this review')
      return
    end
    
    supplier_response = params[:supplier_response]
    
    if supplier_response.blank?
      render_validation_errors(['Supplier response is required'], 'Response failed')
      return
    end
    
    if @review.update(
      supplier_response: supplier_response,
      supplier_response_at: Time.current
    )
      render_success(format_review_data(@review), 'Response added successfully')
    else
      render_validation_errors(@review.errors.full_messages, 'Response failed')
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

  def format_collection_data(reviews)
    reviews.map { |review| format_review_data(review) }
  end

  def format_review_data(review)
    {
      id: review.id,
      product_id: review.product_id,
      user_id: review.user_id,
      user_name: review.user.full_name,
      rating: review.rating,
      title: review.title,
      comment: review.comment,
      is_verified_purchase: review.is_verified_purchase || false,
      is_featured: review.is_featured || false,
      moderation_status: review.moderation_status,
      review_images: review.review_images_list,
      helpful_count: review.helpful_count || 0,
      not_helpful_count: review.not_helpful_count || 0,
      supplier_response: review.supplier_response,
      supplier_response_at: review.supplier_response_at,
      created_at: review.created_at,
      updated_at: review.updated_at
    }
  end
end
