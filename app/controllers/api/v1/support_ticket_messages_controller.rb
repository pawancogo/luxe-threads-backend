# frozen_string_literal: true

class Api::V1::SupportTicketMessagesController < ApplicationController
  before_action :set_support_ticket
  before_action :ensure_ticket_access!
  
  # POST /api/v1/support_tickets/:ticket_id/messages
  def create
    message_params_data = params[:message] || {}
    
    service = SupportTicketMessageCreationService.new(
      @support_ticket,
      message_params_data,
      current_user
    )
    service.call
    
    if service.success?
      render_created(
        SupportTicketMessageSerializer.new(service.message).as_json,
        'Message sent successfully'
      )
    else
      render_validation_errors(service.errors, 'Failed to send message')
    end
  end
  
  private
  
  def set_support_ticket
    @support_ticket = SupportTicket.find(params[:support_ticket_id])
  rescue ActiveRecord::RecordNotFound
    render_not_found('Support ticket not found')
  end
  
  def ensure_ticket_access!
    unless @support_ticket.user_id == current_user.id || current_user.admin?
      render_unauthorized('Not authorized to access this ticket')
    end
  end
  
end

