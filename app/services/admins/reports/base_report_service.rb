# frozen_string_literal: true

# Base class for all report services
# Provides common functionality: date range handling, error handling, period formatting
module Admins
  module Reports
    class BaseReportService < BaseService
      attr_reader :start_date, :end_date

      def initialize(start_date: nil, end_date: nil)
        super()
        @start_date = start_date || 30.days.ago.to_date
        @end_date = end_date || Date.current
      end

      protected

      def period_hash
        {
          start_date: @start_date.iso8601,
          end_date: @end_date.iso8601
        }
      end

      def date_range
        @start_date.beginning_of_day..@end_date.end_of_day
      end

      def fill_missing_dates(stats_hash, default_value = {})
        (@start_date..@end_date).each do |date|
          date_str = date.to_s
          unless stats_hash[date_str]
            stats_hash[date_str] = default_value.merge(date: date.iso8601)
          end
        end
        stats_hash.values.sort_by { |s| s[:date] }
      end

      def calculate_percentage(count, total)
        total > 0 ? ((count.to_f / total) * 100).round(2) : 0
      end
    end
  end
end

