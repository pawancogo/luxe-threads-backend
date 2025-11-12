# frozen_string_literal: true

class Api::V1::NotificationsController < ApplicationController
  # Phase 6: Feature flag check
  before_action :require_notification_feature!
  
  private
  
  def require_notification_feature!
    unless feature_enabled?(:new_notification_system)
      render_error('Notifications feature is not enabled', nil, :service_unavailable)
    end
  end
  
  public
  
  # GET /api/v1/notifications
  def index
    @notifications = current_user.notifications.order(created_at: :desc)
    
    # Filter by read status
    @notifications = @notifications.where(is_read: params[:is_read] == 'true') if params[:is_read].present?
    
    # Filter by type
    @notifications = @notifications.where(notification_type: params[:notification_type]) if params[:notification_type].present?
    
    # Pagination
    @notifications = @notifications.limit(params[:limit] || 50).offset(params[:offset] || 0)
    
    render_success(
      NotificationSerializer.collection(@notifications),
      'Notifications retrieved successfully'
    )
  end

  # GET /api/v1/notifications/:id
  def show
    @notification = current_user.notifications.find(params[:id])
    render_success(
      NotificationSerializer.new(@notification).as_json,
      'Notification retrieved successfully'
    )
  rescue ActiveRecord::RecordNotFound
    render_not_found('Notification not found')
  end

  # PATCH /api/v1/notifications/:id/read
  def mark_as_read
    @notification = current_user.notifications.find(params[:id])
    service = Notifications::MarkReadService.new(@notification)
    service.call
    
    if service.success?
      render_success(
        NotificationSerializer.new(@notification.reload).as_json,
        'Notification marked as read'
      )
    else
      render_validation_errors(service.errors, 'Failed to mark notification as read')
    end
  rescue ActiveRecord::RecordNotFound
    render_not_found('Notification not found')
  end

  # PATCH /api/v1/notifications/mark_all_read
  def mark_all_read
    service = Notifications::MarkAllReadService.new(current_user)
    service.call
    
    if service.success?
      render_success(service.result, 'All notifications marked as read')
    else
      render_validation_errors(service.errors, 'Failed to mark all notifications as read')
    end
  end

  # GET /api/v1/notifications/unread_count
  def unread_count
    count = current_user.notifications.unread.count
    render_success({ count: count }, 'Unread count retrieved successfully')
  end
end

