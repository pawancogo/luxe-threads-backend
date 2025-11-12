# frozen_string_literal: true

class Api::V1::User::StatisticsController < ApplicationController
  # GET /api/v1/user/statistics
  def index
    service = Users::StatisticsService.new(current_user)
    service.call
    
    if service.success?
      render_success(service.stats, 'User statistics retrieved successfully')
    else
      render_error(service.errors.join(', '), :unprocessable_entity)
    end
  end
end

