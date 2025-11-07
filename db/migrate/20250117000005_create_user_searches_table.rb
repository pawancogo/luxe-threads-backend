# frozen_string_literal: true

class CreateUserSearchesTable < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:user_searches)
      create_table :user_searches do |t|
        t.references :user, foreign_key: true # NULL for anonymous
        t.string :session_id, limit: 255
        
        # Search Details
        t.string :search_query, limit: 500, null: false
        t.text :filters, default: '{}' # Applied filters (JSON)
        t.integer :results_count
        
        # Source
        t.string :source, limit: 50 # search_bar, voice, image_search
        
        # Timestamps
        t.timestamp :searched_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
        
        t.timestamps
      end
      
      add_index :user_searches, :search_query unless index_exists?(:user_searches, :search_query)
      add_index :user_searches, :searched_at unless index_exists?(:user_searches, :searched_at)
      add_index :user_searches, :session_id unless index_exists?(:user_searches, :session_id)
    end
  end
end

