# frozen_string_literal: true

module Admins
  module Reports
    class UsersReportService < BaseReportService
      def call
        users = users_scope
        
        set_result({
          summary: calculate_users_summary(users),
          users_by_role: calculate_users_by_role(users),
          new_users_daily: calculate_new_users_daily(users),
          users_activity: calculate_users_activity(users),
          period: period_hash
        })
      rescue StandardError => e
        handle_error(e)
        set_result({})
      end

      private

      def users_scope
        User.where(created_at: date_range)
      end

      def calculate_users_summary(users)
        {
          total_users: users.count,
          customers: users.where.not(role: 'supplier').count,
          suppliers: users.where(role: 'supplier').count,
          active_users: users.where(deleted_at: nil).count,
          inactive_users: users.where.not(deleted_at: nil).count
        }
      end

      def calculate_users_by_role(users)
        total = users.count
        users.group(:role).count.map do |role, count|
          {
            role: role,
            count: count,
            percentage: calculate_percentage(count, total)
          }
        end
      end

      def calculate_new_users_daily(users)
        stats = users.select("DATE(created_at) as date, COUNT(*) as count")
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

      def calculate_users_activity(users)
        active_users = User.joins(:orders)
                          .where(orders: { created_at: date_range })
                          .distinct
                          .count

        {
          active_users: active_users,
          inactive_users: users.count - active_users
        }
      end
    end
  end
end

