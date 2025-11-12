# frozen_string_literal: true

# Service for creating support tickets
module Support
  class CreationService < BaseService
    attr_reader :support_ticket

    def initialize(user, ticket_params)
      super()
      @user = user
      @ticket_params = ticket_params
    end

    def call
      with_transaction do
        create_ticket
        create_initial_message
      end
      set_result(@support_ticket.reload)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def create_ticket
      @support_ticket = @user.support_tickets.build(
        subject: @ticket_params[:subject],
        description: @ticket_params[:description],
        category: @ticket_params[:category] || 'other',
        priority: @ticket_params[:priority] || 'medium',
        order_id: @ticket_params[:order_id],
        product_id: @ticket_params[:product_id]
      )
      
      unless @support_ticket.save
        add_errors(@support_ticket.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @support_ticket
      end
    end

    def create_initial_message
      return unless @ticket_params[:initial_message].present?

      @support_ticket.support_ticket_messages.create!(
        message: @ticket_params[:initial_message],
        sender_type: 'user',
        sender_id: @user.id
      )
    end
  end
end

