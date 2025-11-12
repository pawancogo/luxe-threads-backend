# frozen_string_literal: true

class Api::V1::User::UserSearchesController < ApplicationController
  # GET /api/v1/user/searches
  def index
    @searches = current_user.user_searches.order(searched_at: :desc)
    
    # Filter by date range
    if params[:from_date].present?
      @searches = @searches.where('searched_at >= ?', Date.parse(params[:from_date]))
    end
    
    if params[:to_date].present?
      @searches = @searches.where('searched_at <= ?', Date.parse(params[:to_date]).end_of_day)
    end
    
    # Pagination
    page = params[:page]&.to_i || 1
    per_page = params[:per_page]&.to_i || 20
    total_count = @searches.count
    @searches = @searches.offset((page - 1) * per_page).limit(per_page)
    
    render_success({
      searches: UserSearchSerializer.collection(@searches),
      pagination: {
        current_page: page,
        total_pages: (total_count.to_f / per_page).ceil,
        total_count: total_count,
        per_page: per_page
      }
    }, 'Search history retrieved successfully')
  end

  # POST /api/v1/user/searches
  def create
    service = UserSearchTrackingService.new(
      params[:search][:query] || params[:query],
      user_id: current_user.id,
      session_id: request.headers['X-Session-Id'] || session.id,
      filters: params[:search][:filters] || params[:filters],
      results_count: params[:search][:results_count] || params[:results_count],
      source: params[:search][:source] || params[:source] || 'search_bar'
    )
    service.call
    
    if service.success? && service.user_search.persisted?
      render_created(
        UserSearchSerializer.new(service.user_search).as_json,
        'Search saved successfully'
      )
    else
      errors = service.user_search&.errors&.full_messages || service.errors
      render_validation_errors(errors, 'Failed to save search')
    end
  end

  # DELETE /api/v1/user/searches/:id
  def destroy
    @search = current_user.user_searches.find(params[:id])
    @search.destroy
    render_no_content('Search deleted successfully')
  rescue ActiveRecord::RecordNotFound
    render_not_found('Search not found')
  end

  # DELETE /api/v1/user/searches/clear
  def clear
    service = Users::SearchHistoryClearService.new(current_user)
    service.call
    
    if service.success?
      render_success(service.result, 'Search history cleared successfully')
    else
      render_validation_errors(service.errors, 'Failed to clear search history')
    end
  end

  # GET /api/v1/user/searches/popular
  def popular
    # Get most popular searches for the user
    popular_searches = current_user.user_searches
                                   .group(:search_query)
                                   .order('count(*) DESC')
                                   .limit(params[:limit]&.to_i || 10)
                                   .count
    
    render_success({
      popular_searches: popular_searches.map { |query, count| { query: query, count: count } }
    }, 'Popular searches retrieved successfully')
  end
end

