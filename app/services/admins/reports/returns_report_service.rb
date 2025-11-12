# frozen_string_literal: true

module Admins
  module Reports
    class ReturnsReportService < BaseReportService
      def call
        return_requests = return_requests_scope
        
        set_result({
          summary: calculate_returns_summary(return_requests),
          returns_by_status: calculate_returns_by_status(return_requests),
          returns_by_reason: calculate_returns_by_reason(return_requests),
          daily_returns: calculate_daily_returns(return_requests),
          period: period_hash
        })
      rescue StandardError => e
        handle_error(e)
        set_result({})
      end

      private

      def return_requests_scope
        ReturnRequest.where(created_at: date_range)
      end

      def calculate_returns_summary(return_requests)
        {
          total_returns: return_requests.count,
          approved_returns: return_requests.where(status: 'approved').count,
          rejected_returns: return_requests.where(status: 'rejected').count,
          completed_returns: return_requests.where(status: 'completed').count,
          total_refund_amount: return_requests.where.not(refund_amount: nil).sum(:refund_amount).to_f.round(2)
        }
      end

      def calculate_returns_by_status(return_requests)
        total = return_requests.count
        return_requests.group(:status).count.map do |status, count|
          {
            status: status,
            count: count,
            percentage: calculate_percentage(count, total)
          }
        end
      end

      def calculate_returns_by_reason(return_requests)
        return_requests.joins(:return_request_items)
                       .group('return_request_items.reason')
                       .count
                       .map do |reason, count|
          {
            reason: reason || 'not_specified',
            count: count
          }
        end
      end

      def calculate_daily_returns(return_requests)
        stats = return_requests.select("DATE(created_at) as date, COUNT(*) as count")
                                .group("DATE(created_at)")
                                .order("DATE(created_at)")

        stats_hash = {}
        stats.each do |stat|
          stats_hash[stat.date.to_s] = {
            date: stat.date.iso8601,
            count: stat.count.to_i
          }
        end

        fill_missing_dates(stats_hash, { count: 0 })
      end
    end
  end
end

