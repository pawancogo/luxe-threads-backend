# frozen_string_literal: true

# Service for moderating reviews
module Reviews
  class ModerationService < BaseService
    attr_reader :review

    def initialize(review, moderation_params)
      super()
      @review = review
      @moderation_params = moderation_params
    end

    def call
      with_transaction do
        moderate_review
      end
      set_result(@review)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def moderate_review
      update_hash = {}
      update_hash[:moderation_status] = @moderation_params[:moderation_status] if @moderation_params.key?(:moderation_status)
      update_hash[:is_featured] = @moderation_params[:is_featured] if @moderation_params.key?(:is_featured)
      update_hash[:moderation_notes] = @moderation_params[:moderation_notes] if @moderation_params.key?(:moderation_notes)
      
      unless @review.update(update_hash)
        add_errors(@review.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @review
      end
    end
  end
end

