# frozen_string_literal: true

# Service for creating support ticket messages
class SupportTicketMessageCreationService < BaseService
  attr_reader :message, :support_ticket

  def initialize(support_ticket, message_params, user)
    super()
    @support_ticket = support_ticket
    @message_params = message_params
    @user = user
  end

  def call
    create_message
    update_ticket_status
    set_result(@message)
    self
  rescue StandardError => e
    handle_error(e)
    self
  end

  private

  def create_message
    @message = @support_ticket.support_ticket_messages.build(
      message: @message_params[:message],
      sender_type: @user.admin? ? 'admin' : 'user',
      sender_id: @user.id,
      attachments: @message_params[:attachments]&.to_json || '[]',
      is_internal: @message_params[:is_internal] == true && @user.admin?
    )
    
    unless @message.save
      add_errors(@message.errors.full_messages)
      raise ActiveRecord::RecordInvalid, @message
    end
  end

  def update_ticket_status
    # Update ticket status if customer replies to resolved ticket
    if !@user.admin? && @support_ticket.status == 'resolved'
      @support_ticket.update(status: 'open')
    end
  end
end

