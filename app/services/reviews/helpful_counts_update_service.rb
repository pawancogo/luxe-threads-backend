# frozen_string_literal: true

# Service for updating review helpful counts
module Reviews
  class HelpfulCountsUpdateService < BaseService
    attr_reader :review

    def initialize(review)
      super()
      @review = review
    end

    def call
      with_transaction do
        update_helpful_counts
      end
      set_result(@review)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def update_helpful_counts
      @review.helpful_count = @review.review_helpful_votes.where(is_helpful: true).count
      @review.not_helpful_count = @review.review_helpful_votes.where(is_helpful: false).count
      
      unless @review.save
        add_errors(@review.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @review
      end
    end
  end
end

