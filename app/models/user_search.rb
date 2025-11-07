# frozen_string_literal: true

class UserSearch < ApplicationRecord
  belongs_to :user, optional: true
  
  # Source types
  enum :source, {
    search_bar: 'search_bar',
    voice: 'voice',
    image_search: 'image_search'
  }, default: 'search_bar'
  
  # Parse filters JSON
  def filters_data
    return {} if filters.blank?
    JSON.parse(filters) rescue {}
  end
  
  def filters_data=(data)
    self.filters = data.to_json
  end
  
  scope :recent, -> { order(searched_at: :desc) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_query, ->(query) { where('search_query LIKE ?', "%#{query}%") }
  
  # Track search
  def self.track_search(query, options = {})
    create(
      user_id: options[:user_id],
      session_id: options[:session_id],
      search_query: query,
      filters: options[:filters]&.to_json || '{}',
      results_count: options[:results_count],
      source: options[:source] || 'search_bar',
      searched_at: Time.current
    )
  end
end

