# frozen_string_literal: true

# Service for retrieving user activity
class UserActivityService < BaseService
  attr_reader :activities

  def initialize(user)
    super()
    @user = user
  end

  def call
    build_activities
    set_result(@activities)
    self
  rescue StandardError => e
    handle_error(e)
    self
  end

  private

  def build_activities
    @activities = []
    
    add_order_activities
    add_review_activities
    
    # Sort by timestamp (most recent first)
    @activities.sort_by! { |a| a[:timestamp] }.reverse!
  end

  def add_order_activities
    recent_orders = @user.orders.order(created_at: :desc).limit(10)
    
    recent_orders.each do |order|
      @activities << {
        type: 'order',
        action: 'created',
        resource_id: order.id,
        timestamp: order.created_at,
        data: {
          order_number: order.order_number,
          status: order.status
        }
      }
    end
  end

  def add_review_activities
    return unless @user.respond_to?(:reviews)
    
    recent_reviews = @user.reviews.order(created_at: :desc).limit(10)
    
    recent_reviews.each do |review|
      @activities << {
        type: 'review',
        action: 'created',
        resource_id: review.id,
        timestamp: review.created_at,
        data: {
          product_id: review.product_id,
          rating: review.rating
        }
      }
    end
  end
end

