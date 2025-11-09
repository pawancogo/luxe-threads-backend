# frozen_string_literal: true

class ReviewHelpfulVote < ApplicationRecord
  belongs_to :review
  belongs_to :user
  
  validates :user_id, uniqueness: { scope: :review_id, message: "has already voted on this review" }
  
  # Update helpful counts after save
  after_save :update_review_counts
  after_destroy :update_review_counts
  
  private
  
  def update_review_counts
    review.update_helpful_counts
  end
end



