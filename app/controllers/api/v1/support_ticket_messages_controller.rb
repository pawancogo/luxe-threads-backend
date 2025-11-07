# frozen_string_literal: true

class Api::V1::SupportTicketMessagesController < ApplicationController
  before_action :set_support_ticket
  before_action :ensure_ticket_access!
  
  # POST /api/v1/support_tickets/:ticket_id/messages
  def create
    message_params_data = params[:message] || {}
    
    @message = @support_ticket.support_ticket_messages.build(
      message: message_params_data[:message],
      sender_type: current_user.admin? ? 'admin' : 'user',
      sender_id: current_user.admin? ? current_user.id : current_user.id,
      attachments: message_params_data[:attachments]&.to_json || '[]',
      is_internal: message_params_data[:is_internal] == true && current_user.admin?
    )
    
    if @message.save
      # Update ticket status if customer replies
      if !current_user.admin? && @support_ticket.status == 'resolved'
        @support_ticket.update(status: 'open')
      end
      
      render_created(format_message_data(@message), 'Message sent successfully')
    else
      render_validation_errors(@message.errors.full_messages, 'Failed to send message')
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
  
  def format_message_data(message)
    {
      id: message.id,
      message: message.message,
      sender_type: message.sender_type,
      sender_name: message.sender&.full_name || 'Support',
      attachments: message.attachments_list,
      is_internal: message.is_internal,
      is_read: message.is_read,
      created_at: message.created_at
    }
  end
end

