# frozen_string_literal: true

class EnhanceReviewsTable < ActiveRecord::Migration[7.1]
  def change
    # Add new columns if they don't exist
    add_column :reviews, :title, :string, limit: 255 unless column_exists?(:reviews, :title)
    add_column :reviews, :is_featured, :boolean, default: false unless column_exists?(:reviews, :is_featured)
    add_column :reviews, :review_images, :text unless column_exists?(:reviews, :review_images) # JSONB -> TEXT for SQLite
    add_column :reviews, :moderation_status, :string, limit: 50, default: 'pending' unless column_exists?(:reviews, :moderation_status)
    add_column :reviews, :moderated_by_id, :integer unless column_exists?(:reviews, :moderated_by_id)
    add_column :reviews, :moderated_at, :timestamp unless column_exists?(:reviews, :moderated_at)
    add_column :reviews, :moderation_notes, :text unless column_exists?(:reviews, :moderation_notes)
    add_column :reviews, :supplier_response, :text unless column_exists?(:reviews, :supplier_response)
    add_column :reviews, :supplier_response_at, :timestamp unless column_exists?(:reviews, :supplier_response_at)
    add_column :reviews, :helpful_count, :integer, default: 0 unless column_exists?(:reviews, :helpful_count)
    add_column :reviews, :not_helpful_count, :integer, default: 0 unless column_exists?(:reviews, :not_helpful_count)
    
    # Add indexes
    add_index :reviews, :moderation_status unless index_exists?(:reviews, :moderation_status)
    add_index :reviews, :is_featured unless index_exists?(:reviews, :is_featured)
    add_index :reviews, :moderated_by_id unless index_exists?(:reviews, :moderated_by_id)
  end
end



