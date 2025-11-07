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
    
    render_success(format_notifications_data(@notifications), 'Notifications retrieved successfully')
  end
  
  # GET /api/v1/notifications/:id
  def show
    @notification = current_user.notifications.find(params[:id])
    render_success(format_notification_data(@notification), 'Notification retrieved successfully')
  rescue ActiveRecord::RecordNotFound
    render_not_found('Notification not found')
  end
  
  # PATCH /api/v1/notifications/:id/read
  def mark_as_read
    @notification = current_user.notifications.find(params[:id])
    @notification.mark_as_read!
    render_success(format_notification_data(@notification), 'Notification marked as read')
  rescue ActiveRecord::RecordNotFound
    render_not_found('Notification not found')
  end
  
  # PATCH /api/v1/notifications/mark_all_read
  def mark_all_read
    current_user.notifications.unread.update_all(is_read: true, read_at: Time.current)
    render_success({ count: current_user.notifications.unread.count }, 'All notifications marked as read')
  end
  
  # GET /api/v1/notifications/unread_count
  def unread_count
    count = current_user.notifications.unread.count
    render_success({ count: count }, 'Unread count retrieved successfully')
  end
  
  private
  
  def format_notifications_data(notifications)
    notifications.map { |notification| format_notification_data(notification) }
  end
  
  def format_notification_data(notification)
    {
      id: notification.id,
      title: notification.title,
      message: notification.message,
      notification_type: notification.notification_type,
      data: notification.data_hash,
      is_read: notification.is_read,
      read_at: notification.read_at,
      created_at: notification.created_at
    }
  end
end

