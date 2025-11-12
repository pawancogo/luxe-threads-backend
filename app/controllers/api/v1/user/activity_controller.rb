# frozen_string_literal: true

class Api::V1::User::ActivityController < ApplicationController
  # GET /api/v1/user/activity
  def index
    activities = []
    
    # Recent orders
    recent_orders = current_user.orders.order(created_at: :desc).limit(10)
    recent_orders.each do |order|
      activities << {
        type: 'order',
        action: 'placed',
        description: "Order ##{order.order_number || order.id} placed",
        amount: order.total_amount,
        status: order.status,
        created_at: order.created_at.iso8601,
        metadata: {
          order_id: order.id,
          order_number: order.order_number || order.id.to_s.rjust(8, '0')
        }
      }
    end
    
    # Recent reviews
    recent_reviews = current_user.reviews.order(created_at: :desc).limit(10)
    recent_reviews.each do |review|
      activities << {
        type: 'review',
        action: 'created',
        description: "Review for #{review.product.name}",
        rating: review.rating,
        created_at: review.created_at.iso8601,
        metadata: {
          review_id: review.id,
          product_id: review.product_id
        }
      }
    end
    
    # Recent returns
    if defined?(ReturnRequest) && ReturnRequest.table_exists?
      recent_returns = current_user.support_tickets.where(ticket_type: 'return').order(created_at: :desc).limit(10)
      recent_returns.each do |return_request|
        activities << {
          type: 'return',
          action: 'requested',
          description: "Return request for Order ##{return_request.order_id}",
          status: return_request.status,
          created_at: return_request.created_at.iso8601,
          metadata: {
            return_id: return_request.id,
            order_id: return_request.order_id
          }
        }
      end
    end
    
    # Sort by created_at descending
    activities.sort_by! { |a| a[:created_at] }.reverse!
    
    # Pagination
    page = params[:page]&.to_i || 1
    per_page = params[:per_page]&.to_i || 20
    total_count = activities.count
    paginated_activities = activities.slice((page - 1) * per_page, per_page) || []
    
    render_success({
      activities: paginated_activities,
      pagination: {
        current_page: page,
        total_pages: (total_count.to_f / per_page).ceil,
        total_count: total_count,
        per_page: per_page
      }
    }, 'User activity retrieved successfully')
  end
end

