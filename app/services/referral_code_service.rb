# frozen_string_literal: true

# Service for managing referral codes
class ReferralCodeService < BaseService
  attr_reader :referral_code, :referral_url, :stats

  def initialize(user, base_url = nil)
    super()
    @user = user
    @base_url = base_url
  end

  def call
    generate_or_get_code
    build_referral_url
    calculate_stats
    set_result({
      referral_code: @referral_code,
      referral_url: @referral_url,
      stats: @stats
    })
    self
  rescue StandardError => e
    handle_error(e)
    self
  end

  private

  def generate_or_get_code
    service = UserReferralCodeService.new(@user)
    service.call
    @referral_code = service.referral_code
  end

  def build_referral_url
    return unless @base_url

    @referral_url = "#{@base_url}/signup?ref=#{@referral_code}"
  end

  def calculate_stats
    @stats = {
      total_referrals: @user.referrals.count,
      completed_referrals: @user.referrals.completed.count,
      rewarded_referrals: @user.referrals.rewarded.count
    }
  end
end


