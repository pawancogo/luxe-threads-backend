# frozen_string_literal: true

class CreateSearchSuggestionsTable < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:search_suggestions)
      create_table :search_suggestions do |t|
        # Suggestion
        t.string :query, limit: 500, null: false
        t.string :suggestion_type, limit: 50, null: false
        # Values: product, category, brand, trending
        
        # Reference
        t.integer :reference_id
        t.string :reference_type, limit: 50
        
        # Popularity
        t.integer :search_count, default: 0
        t.integer :click_count, default: 0
        
        # Display
        t.string :display_text, limit: 500
        t.string :image_url, limit: 500
        
        # Status
        t.boolean :is_active, default: true
        
        t.timestamps
      end
      
      add_index :search_suggestions, :query
      add_index :search_suggestions, :suggestion_type
      add_index :search_suggestions, :is_active
      add_index :search_suggestions, :search_count
    end
  end
end

