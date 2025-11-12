# frozen_string_literal: true

# Refactored ReferralsController using Clean Architecture
# Controller → Service → Model → Serializer
class Api::V1::ReferralsController < ApplicationController
  # GET /api/v1/referrals/code
  def code
    service = ReferralCodeService.new(current_user, request.base_url)
    service.call
    
    if service.success?
      render_success(service.result, 'Referral code retrieved successfully')
    else
      render_error(service.errors.first || 'Failed to retrieve referral code')
    end
  end

  # GET /api/v1/referrals
  def index
    referrals = Referral.for_customer(current_user.id).with_referred_customer
    referrals = referrals.where(status: params[:status]) if params[:status].present?
    
    # Pagination
    page = params[:page]&.to_i || 1
    per_page = params[:per_page]&.to_i || 20
    total_count = referrals.count
    referrals = referrals.order(created_at: :desc)
                         .offset((page - 1) * per_page)
                         .limit(per_page)
    
    serialized_referrals = referrals.map { |referral| ReferralSerializer.new(referral).as_json }
    
    render_success({
      referrals: serialized_referrals,
      pagination: {
        current_page: page,
        total_pages: (total_count.to_f / per_page).ceil,
        total_count: total_count,
        per_page: per_page
      }
    }, 'Referrals retrieved successfully')
  end

  # GET /api/v1/referrals/stats
  def stats
    service = ReferralCodeService.new(current_user)
    service.call
    
    stats = service.stats.merge(
      pending_referrals: current_user.referrals.pending.count,
      referral_code: service.referral_code
    )
    
    render_success(stats, 'Referral statistics retrieved successfully')
  end
end

