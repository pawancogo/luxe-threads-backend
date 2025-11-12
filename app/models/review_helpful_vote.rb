# frozen_string_literal: true

class ReviewHelpfulVote < ApplicationRecord
  belongs_to :review
  belongs_to :user
  
  validates :user_id, uniqueness: { scope: :review_id, message: "has already voted on this review" }
  
  # Note: Callbacks removed - use Reviews::HelpfulCountsUpdateService instead
  # Call the service after creating/updating/destroying votes
end



