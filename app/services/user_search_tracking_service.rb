# frozen_string_literal: true

# Service for tracking user searches
class UserSearchTrackingService < BaseService
  attr_reader :user_search

  def initialize(query, user_id:, session_id: nil, filters: nil, results_count: nil, source: 'search_bar')
    super()
    @query = query
    @user_id = user_id
    @session_id = session_id
    @filters = filters
    @results_count = results_count
    @source = source
  end

  def call
    track_search
    set_result(@user_search)
    self
  rescue StandardError => e
    handle_error(e)
    self
  end

  private

  def track_search
    @user_search = UserSearch.track_search(
      @query,
      user_id: @user_id,
      session_id: @session_id,
      filters: @filters,
      results_count: @results_count,
      source: @source
    )
  end
end

