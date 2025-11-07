# frozen_string_literal: true

class Api::V1::SupportTicketsController < ApplicationController
  # Phase 6: Feature flag check
  before_action :require_support_tickets_feature!
  before_action :authorize_admin!, only: [:admin_index, :admin_show, :admin_assign, :admin_resolve, :admin_close]
  before_action :set_support_ticket, only: [:show, :update, :admin_show, :admin_assign, :admin_resolve, :admin_close]
  
  # GET /api/v1/support_tickets (customer view)
  def index
    @tickets = current_user.support_tickets.includes(:support_ticket_messages).order(created_at: :desc)
    
    # Filter by status
    @tickets = @tickets.where(status: params[:status]) if params[:status].present?
    
    render_success(format_tickets_data(@tickets), 'Support tickets retrieved successfully')
  end
  
  # GET /api/v1/support_tickets/:id
  def show
    ensure_ticket_ownership!
    render_success(format_ticket_detail_data(@support_ticket), 'Support ticket retrieved successfully')
  end
  
  # POST /api/v1/support_tickets
  def create
    ticket_params_data = params[:support_ticket] || {}
    
    @support_ticket = current_user.support_tickets.build(
      subject: ticket_params_data[:subject],
      description: ticket_params_data[:description],
      category: ticket_params_data[:category] || 'other',
      priority: ticket_params_data[:priority] || 'medium',
      order_id: ticket_params_data[:order_id],
      product_id: ticket_params_data[:product_id]
    )
    
    if @support_ticket.save
      # Create initial message if provided
      if ticket_params_data[:initial_message].present?
        @support_ticket.support_ticket_messages.create!(
          message: ticket_params_data[:initial_message],
          sender_type: 'user',
          sender_id: current_user.id
        )
      end
      
      render_created(format_ticket_detail_data(@support_ticket.reload), 'Support ticket created successfully')
    else
      render_validation_errors(@support_ticket.errors.full_messages, 'Failed to create support ticket')
    end
  end
  
  # GET /api/v1/admin/support_tickets
  def admin_index
    @tickets = SupportTicket.includes(:user, :assigned_to, :support_ticket_messages).order(created_at: :desc)
    
    # Filters
    @tickets = @tickets.where(status: params[:status]) if params[:status].present?
    @tickets = @tickets.where(priority: params[:priority]) if params[:priority].present?
    @tickets = @tickets.where(assigned_to_id: params[:assigned_to_id]) if params[:assigned_to_id].present?
    @tickets = @tickets.where(category: params[:category]) if params[:category].present?
    
    render_success(format_tickets_data(@tickets), 'Support tickets retrieved successfully')
  end
  
  # GET /api/v1/admin/support_tickets/:id
  def admin_show
    render_success(format_ticket_detail_data(@support_ticket), 'Support ticket retrieved successfully')
  end
  
  # PATCH /api/v1/admin/support_tickets/:id/assign
  def admin_assign
    admin_id = params[:assigned_to_id] || current_user.id
    admin = Admin.find(admin_id)
    
    @support_ticket.assign_to!(admin)
    render_success(format_ticket_detail_data(@support_ticket), 'Ticket assigned successfully')
  end
  
  # PATCH /api/v1/admin/support_tickets/:id/resolve
  def admin_resolve
    resolution = params[:resolution]
    @support_ticket.resolve!(current_user, resolution)
    render_success(format_ticket_detail_data(@support_ticket), 'Ticket resolved successfully')
  end
  
  # PATCH /api/v1/admin/support_tickets/:id/close
  def admin_close
    @support_ticket.close!
    render_success(format_ticket_detail_data(@support_ticket), 'Ticket closed successfully')
  end
  
  private
  
  def set_support_ticket
    @support_ticket = SupportTicket.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found('Support ticket not found')
  end
  
  def ensure_ticket_ownership!
    unless @support_ticket.user_id == current_user.id || current_user.admin?
      render_unauthorized('Not authorized to access this ticket')
    end
  end
  
  def authorize_admin!
    render_unauthorized('Admin access required') unless current_user&.admin?
  end
  
  def format_tickets_data(tickets)
    tickets.map { |ticket| format_ticket_data(ticket) }
  end
  
  def format_ticket_data(ticket)
    {
      id: ticket.id,
      ticket_id: ticket.ticket_id,
      subject: ticket.subject,
      category: ticket.category,
      status: ticket.status,
      priority: ticket.priority,
      created_at: ticket.created_at,
      assigned_to: ticket.assigned_to&.full_name,
      message_count: ticket.support_ticket_messages.count
    }
  end
  
  def format_ticket_detail_data(ticket)
    format_ticket_data(ticket).merge(
      description: ticket.description,
      resolution: ticket.resolution,
      resolved_at: ticket.resolved_at,
      resolved_by: ticket.resolved_by&.full_name,
      assigned_at: ticket.assigned_at,
      closed_at: ticket.closed_at,
      order_id: ticket.order_id,
      product_id: ticket.product_id,
      messages: ticket.support_ticket_messages.visible_to_user.map do |message|
        {
          id: message.id,
          message: message.message,
          sender_type: message.sender_type,
          sender_name: message.sender&.full_name || 'Support',
          attachments: message.attachments_list,
          is_read: message.is_read,
          created_at: message.created_at
        }
      end
    )
  end
  
  private
  
  def require_support_tickets_feature!
    unless feature_enabled?(:support_tickets)
      render_error('Support tickets feature is not enabled', nil, :service_unavailable)
    end
  end
end

