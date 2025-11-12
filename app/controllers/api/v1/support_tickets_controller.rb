# frozen_string_literal: true

# Refactored SupportTicketsController using Clean Architecture
# Controller → Service → Model → Serializer
class Api::V1::SupportTicketsController < ApplicationController
  # Phase 6: Feature flag check
  before_action :require_support_tickets_feature!
  before_action :authorize_admin!, only: [:admin_index, :admin_show, :admin_assign, :admin_resolve, :admin_close]
  before_action :set_support_ticket, only: [:show, :update, :admin_show, :admin_assign, :admin_resolve, :admin_close]
  
  # GET /api/v1/support_tickets (customer view)
  def index
    tickets = SupportTicket.for_customer(current_user.id).recent
    tickets = tickets.by_status(params[:status]) if params[:status].present?
    
    serialized_tickets = tickets.map { |ticket| SupportTicketSerializer.new(ticket).as_json }
    render_success(serialized_tickets, 'Support tickets retrieved successfully')
  end
  
  # GET /api/v1/support_tickets/:id
  def show
    ensure_ticket_ownership!
    render_success(
      SupportTicketSerializer.new(@support_ticket).detailed,
      'Support ticket retrieved successfully'
    )
  end
  
  # POST /api/v1/support_tickets
  def create
    service = Support::CreationService.new(current_user, params[:support_ticket] || {})
    service.call
    
    if service.success?
      render_created(
        SupportTicketSerializer.new(service.support_ticket).detailed,
        'Support ticket created successfully'
      )
    else
      render_validation_errors(service.errors, 'Failed to create support ticket')
    end
  end
  
  # GET /api/v1/admin/support_tickets
  def admin_index
    tickets = SupportTicket.with_full_details.recent
    tickets = tickets.by_status(params[:status]) if params[:status].present?
    tickets = tickets.by_priority(params[:priority]) if params[:priority].present?
    tickets = tickets.assigned_to_admin(params[:assigned_to_id]) if params[:assigned_to_id].present?
    tickets = tickets.by_category(params[:category]) if params[:category].present?
    
    serialized_tickets = tickets.map { |ticket| SupportTicketSerializer.new(ticket).as_json }
    render_success(serialized_tickets, 'Support tickets retrieved successfully')
  end
  
  # GET /api/v1/admin/support_tickets/:id
  def admin_show
    render_success(
      SupportTicketSerializer.new(@support_ticket).detailed,
      'Support ticket retrieved successfully'
    )
  end
  
  # PATCH /api/v1/admin/support_tickets/:id/assign
  def admin_assign
    admin_id = params[:assigned_to_id] || current_user.id
    admin = Admin.find(admin_id)
    
    service = Support::AssignmentService.new(@support_ticket, admin)
    service.call
    
    if service.success?
      render_success(
        SupportTicketSerializer.new(@support_ticket.reload).detailed,
        'Ticket assigned successfully'
      )
    else
      render_validation_errors(service.errors, 'Failed to assign ticket')
    end
  end
  
  # PATCH /api/v1/admin/support_tickets/:id/resolve
  def admin_resolve
    service = Support::ResolutionService.new(@support_ticket, current_user, params[:resolution])
    service.call
    
    if service.success?
      render_success(
        SupportTicketSerializer.new(@support_ticket.reload).detailed,
        'Ticket resolved successfully'
      )
    else
      render_validation_errors(service.errors, 'Failed to resolve ticket')
    end
  end
  
  # PATCH /api/v1/admin/support_tickets/:id/close
  def admin_close
    service = Support::ClosureService.new(@support_ticket)
    service.call
    
    if service.success?
      render_success(
        SupportTicketSerializer.new(@support_ticket.reload).detailed,
        'Ticket closed successfully'
      )
    else
      render_validation_errors(service.errors, 'Failed to close ticket')
    end
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
  
  def require_support_tickets_feature!
    unless feature_enabled?(:support_tickets)
      render_error('Support tickets feature is not enabled', nil, :service_unavailable)
    end
  end
end

