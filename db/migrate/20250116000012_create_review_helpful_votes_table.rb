# frozen_string_literal: true

class CreateReviewHelpfulVotesTable < ActiveRecord::Migration[7.1]
  def change
    create_table :review_helpful_votes do |t|
      t.references :review, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      
      # Vote
      t.boolean :is_helpful, null: false, default: true
      
      t.timestamps
    end
    
    add_index :review_helpful_votes, [:review_id, :user_id], unique: true unless index_exists?(:review_helpful_votes, [:review_id, :user_id])
    add_index :review_helpful_votes, :is_helpful unless index_exists?(:review_helpful_votes, :is_helpful)
  end
end

