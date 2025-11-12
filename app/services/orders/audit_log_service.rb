# frozen_string_literal: true

# Service for retrieving order audit logs
module Orders
  class AuditLogService < BaseService
    attr_reader :audit_entries

    def initialize(order)
      super()
      @order = order
    end

    def call
      build_audit_log
      set_result(@audit_entries)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def build_audit_log
      @audit_entries = []
      
      add_papertrail_versions
      add_status_history_entries
      
      # Sort by timestamp (most recent first)
      @audit_entries.sort_by! { |e| e[:timestamp] || Time.current }.reverse!
    end

    def add_papertrail_versions
      versions = @order.versions.order(created_at: :desc)
      
      versions.each do |version|
        @audit_entries << {
          type: 'version',
          event: version.event,
          timestamp: version.created_at,
          whodunnit: version.whodunnit,
          changes: version.changeset,
          admin_id: version.whodunnit&.match(/admin_(\d+)/)&.captures&.first
        }
      end
    end

    def add_status_history_entries
      status_history = @order.status_history_array
      
      status_history.each do |entry|
        @audit_entries << {
          type: 'status_change',
          status: entry['status'],
          timestamp: entry['timestamp'],
          note: entry['note']
        }
      end
    end
  end
end

