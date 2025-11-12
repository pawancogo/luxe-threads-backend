# frozen_string_literal: true

# Service for voting on reviews
module Reviews
  class VoteService < BaseService
    attr_reader :review, :vote

    def initialize(review, user, is_helpful)
      super()
      @review = review
      @user = user
      @is_helpful = is_helpful == 'true' || is_helpful == true
    end

    def call
      with_transaction do
        create_or_update_vote
        update_helpful_counts
      end
      set_result(@review)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def create_or_update_vote
      @vote = @review.review_helpful_votes.find_or_initialize_by(user: @user)
      @vote.is_helpful = @is_helpful
      
      unless @vote.save
        add_errors(@vote.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @vote
      end
    end

    def update_helpful_counts
      service = Reviews::HelpfulCountsUpdateService.new(@review)
      service.call
      
      unless service.success?
        add_errors(service.errors)
        raise StandardError, 'Failed to update helpful counts'
      end
    end
  end
end

